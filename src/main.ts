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

const app = createApp(App)
const pinia = createPinia()
app.use(pinia)

// Initialize auth store
const authStore = useAuthStore()

console.log('[App] Initializing auth...')
const { data: { session }, error } = await supabase.auth.getSession()

if (error) {
  console.error('[App] Error checking session:', error)
}

if (session?.user) {
  console.log('[App] Found existing session, restoring...', {
    user: session.user.email,
    expires_at: new Date(session.expires_at! * 1000).toISOString()
  })
  try {
    // Let the auth state listener handle the session
    const { data, error } = await supabase.auth.setSession(session)
    if (error) throw error
    console.log('[App] Session restored successfully:', {
      user: data.user?.email,
      event: data.session ? 'session_restored' : 'no_session'
    })
    
    // Wait for auth state to stabilize after session restoration
    await new Promise(resolve => {
      let stopWatching: (() => void) | null = null
      
      const handleLoadingChange = (loading: boolean) => {
        console.log('[App] Auth loading state changed:', { loading })
        if (!loading) {
          stopWatching?.()
          resolve(true)
        }
      }

      stopWatching = watch(() => authStore.loading, handleLoadingChange, { immediate: true })
    });
  } catch (error) {
    console.error('[App] Failed to restore session:', error)
  }
} else {
  console.log('[App] No existing session found')
}

console.log('[App] Auth initialized:', {
  isAuthenticated: authStore.isAuthenticated,
  loading: authStore.loading,
  hasUser: !!authStore.user,
  hasSession: !!authStore.session
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
    loading: authStore.loading
  });

  // Wait for auth to finish loading
  if (authStore.loading) {
    console.log('[Router] Auth still loading, waiting...');
    await new Promise(resolve => {
      let stopWatching: (() => void) | null = null
      
      const handleLoadingChange = (loading: boolean) => {
        console.log('[Router] Auth loading state changed:', { loading })
        if (!loading) {
          stopWatching?.()
          resolve(true)
        }
      }

      stopWatching = watch(() => authStore.loading, handleLoadingChange, { immediate: true })
    });
  }

  // After session check, handle route guards
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    console.log('[Router] Route requires auth but user is not authenticated, redirecting to auth');
    next({ name: 'auth' });
    return;
  }

  // If going to auth page while authenticated, redirect to home
  if (to.name === 'auth' && authStore.isAuthenticated) {
    console.log('[Router] User is authenticated, redirecting to home');
    next({ name: 'home' });
    return;
  }

  console.log('[Router] Navigation allowed');
  next();
});

// Mount app after router
app.use(router)

// Error handling for app mounting
try {
  app.mount('#app')
  console.log('[App] Successfully mounted');
} catch (error) {
  console.error('[App] Error mounting app:', error);
  document.getElementById('app')!.innerHTML = `
    <div class="min-h-screen flex items-center justify-center bg-gray-50">
      <div class="text-center">
        <h1 class="text-2xl font-bold text-red-600 mb-4">Application Error</h1>
        <p class="text-gray-600">An error occurred while loading the application. Please try refreshing the page.</p>
        <button onclick="window.location.reload()" class="mt-4 px-4 py-2 bg-red-100 text-red-700 rounded hover:bg-red-200">
          Refresh Page
        </button>
      </div>
    </div>
  `;
}

// Debug output
console.log('Available routes:', router.getRoutes().map(r => ({ 
  path: r.path,
  name: r.name
})))