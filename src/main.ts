import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { watch } from 'vue'
import App from './App.vue'
import './index.css'
import router from './routes'
import { useAuthStore } from './stores/auth'
import { supabase } from './lib/supabase'

// Error handling
window.onerror = function(msg, url, line, col, error) {
  console.error('Global error:', { msg, url, line, col, error });
  return false;
};

// Create app instance
console.log('[App] Creating app instance...')
console.log('[App] Supabase URL:', import.meta.env.VITE_SUPABASE_URL)
console.log('[App] Supabase Anon Key:', import.meta.env.VITE_SUPABASE_ANON_KEY ? 'Present' : 'Missing')
const app = createApp(App)
const pinia = createPinia()
app.use(pinia)

// Initialize auth store AFTER Pinia is set up
console.log('[App] Initializing auth store...')
const authStore = useAuthStore()

// Debug logging to verify store methods
console.log('[DEBUG] Store methods:', {
  setSession: typeof authStore.setSession,
  resetState: typeof authStore.resetState,
  registerAuthListener: typeof authStore.registerAuthListener,
  initialize: typeof authStore.initialize,
  signIn: typeof authStore.signIn
})

console.log('[DEBUG] Store keys:', Object.keys(authStore))

// Initialize auth with timeout protection
console.log('[App] Starting auth initialization...')
let authInitialized = false

// Function to check Supabase connection
async function checkSupabaseConnection(): Promise<boolean> {
  try {
    console.log('[App] Testing Supabase connection...')
    const start = Date.now()
    const { error } = await supabase.from('profiles').select('id').limit(1)
    const duration = Date.now() - start
    console.log(`[App] Supabase connection test took ${duration}ms`)
    
    if (error) {
      console.error('[App] Supabase connection test failed:', error)
      return false
    }
    return true
  } catch (err) {
    console.error('[App] Supabase connection test error:', err)
    return false
  }
}

// Set a timeout to prevent infinite loading
const timeout = setTimeout(() => {
  if (!authInitialized) {
    console.error('[App] Auth initialization timed out after 10 seconds')
    authStore.resetState()
    mountApp()
  }
}, 10000)

async function waitForAuthState(): Promise<void> {
  return new Promise<void>((resolve, reject) => {
    const timeout = setTimeout(() => {
      reject(new Error('Auth state watch timed out'))
    }, 5000)

    let unwatch: (() => void) | undefined
    
    try {
      unwatch = watch(
        () => ({
          loading: authStore.loading,
          isAuthenticated: authStore.isAuthenticated,
          hasUser: !!authStore.user,
          hasSession: !!authStore.session
        }),
        (newState) => {
          console.log('[App] Auth state changed:', newState)
          if (!newState.loading) {
            if (unwatch) {
              unwatch()
              clearTimeout(timeout)
              resolve()
            }
          }
        },
        { immediate: true }
      )
    } catch (error) {
      clearTimeout(timeout)
      if (unwatch) unwatch()
      reject(error)
    }
  })
}

async function initializeAuth() {
  try {
    // Check Supabase connection first
    const isConnected = await checkSupabaseConnection()
    if (!isConnected) {
      throw new Error('Failed to connect to Supabase')
    }

    console.log('[App] Checking session...')
    const sessionStart = Date.now()
    const { data: { session }, error } = await supabase.auth.getSession()
    console.log(`[App] getSession took ${Date.now() - sessionStart}ms`)

    if (error) {
      console.error('[App] Error checking session:', error)
      throw error
    }

    if (session?.user) {
      console.log('[App] Found existing session:', {
        user: session.user.email,
        expires_at: new Date(session.expires_at! * 1000).toISOString(),
        session_id: session.access_token?.slice(-6)
      })

      // Set the session in the store
      const setSessionStart = Date.now()
      await authStore.setSession(session)
      console.log(`[App] setSession took ${Date.now() - setSessionStart}ms`)
      
      // Register auth listener AFTER setting the session
      console.log('[App] Registering auth listener...')
      authStore.registerAuthListener()
      
      // Wait for auth state to stabilize
      try {
        await waitForAuthState()
        console.log('[App] Auth initialized successfully:', {
          isAuthenticated: authStore.isAuthenticated,
          loading: authStore.loading,
          hasUser: !!authStore.user,
          hasSession: !!authStore.session,
          hasProfile: !!authStore.profile,
          companies: authStore.availableCompanies?.length,
          currentCompanyId: authStore.currentCompanyId
        })
      } catch (error) {
        console.error('[App] Error waiting for auth state:', error)
        throw error
      }
    } else {
      console.log('[App] No existing session')
      authStore.resetState()
      authStore.registerAuthListener()
    }
  } catch (error) {
    console.error('[App] Auth initialization failed:', error)
    authStore.resetState()
  } finally {
    authInitialized = true
    clearTimeout(timeout)
    mountApp()
  }
}

function mountApp() {
  if (!app._container) {
    console.log('[App] Mounting app...')
    app.use(router)
    app.mount('#app')
    console.log('[App] Successfully mounted')
  }
}

// Start auth initialization
initializeAuth().catch(error => {
  console.error('[App] Unhandled auth initialization error:', error)
  authStore.resetState()
  mountApp()
})

// Setup navigation guards
router.beforeEach(async (to, from, next) => {
  console.log('[Router] Navigation:', {
    to: to.fullPath,
    from: from.fullPath,
    toName: to.name,
    fromName: from.name,
    requiresAuth: to.meta.requiresAuth,
    isAuthenticated: authStore.isAuthenticated,
    loading: authStore.loading,
    hasUser: !!authStore.user,
    hasSession: !!authStore.session
  })

  // Wait for auth to finish loading with timeout
  if (authStore.loading) {
    console.log('[Router] Auth still loading, waiting...')
    try {
      await waitForAuthState()
    } catch (error) {
      console.error('[Router] Auth loading timeout:', error)
      authStore.resetState()
    }
  }

  // After session check, handle route guards
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    console.log('[Router] Route requires auth but user is not authenticated, redirecting to auth')
    next({ name: 'auth' })
    return
  }

  // If going to auth page while authenticated, redirect to home
  if (to.name === 'auth' && authStore.isAuthenticated) {
    console.log('[Router] User is authenticated, redirecting to home')
    next({ name: 'home' })
    return
  }

  console.log('[Router] Navigation allowed')
  next()
})

// Debug output
console.log('[App] Available routes:', router.getRoutes().map(r => ({ 
  path: r.path,
  name: r.name
})))