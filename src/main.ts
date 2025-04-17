import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import './index.css'
import router from './routes'
import { useAuthStore } from './stores/auth'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)

// Initialize auth store
const authStore = useAuthStore()

// Setup navigation guards
router.beforeEach(async (to, from, next) => {
  try {
    // Always fetch user data if not authenticated
    if (!authStore.isAuthenticated) {
      await authStore.fetchUser()
    }

    // Handle authentication requirements
    if (to.meta.requiresAuth && !authStore.isAuthenticated) {
      next({ name: 'auth' })
      return
    }

    if (to.name === 'auth' && authStore.isAuthenticated) {
      next({ name: 'home' })
      return
    }

    next()
  } catch (error) {
    console.error('Navigation error:', error)
    next({ name: 'auth' })
  }
})

// Mount app after router
app.use(router)
app.mount('#app')

// Debug output
console.log('Available routes:', router.getRoutes().map(r => ({ 
  path: r.path,
  name: r.name
})))