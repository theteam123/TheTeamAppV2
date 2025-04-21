import { createRouter, createWebHistory, RouteRecordRaw, NavigationGuardNext, RouteLocationNormalized } from 'vue-router';
import { useAuthStore } from '../stores/auth';

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    name: 'home',
    component: () => import('../pages/Home.vue'),
    meta: {
      requiresAuth: true
    }
  },
  {
    path: '/login',
    name: 'login',
    component: () => import('../pages/Login.vue'),
    meta: {
      requiresAuth: false
    }
  },
  {
    path: '/company-select',
    name: 'company-select',
    component: () => import('../pages/CompanySelect.vue'),
    meta: {
      requiresAuth: true,
      layout: 'blank'
    }
  },
  {
    path: '/dashboard',
    name: 'dashboard',
    component: () => import('../pages/Dashboard.vue'),
    meta: {
      requiresAuth: true
    }
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

// Navigation guard
router.beforeEach(async (
  to: RouteLocationNormalized,
  from: RouteLocationNormalized,
  next: NavigationGuardNext
) => {
  const auth = useAuthStore();
  const isAuthenticated = auth.isAuthenticated;

  // Check if route requires authentication
  if (to.meta.requiresAuth && !isAuthenticated) {
    return next({ name: 'login' });
  }

  // Check if company selection is needed
  if (isAuthenticated && auth.needsCompanySelection && to.name !== 'company-select') {
    return next({ name: 'company-select' });
  }

  // If authenticated and company is selected, redirect to dashboard
  if (isAuthenticated && !auth.needsCompanySelection && to.name === 'company-select') {
    return next({ name: 'dashboard' });
  }

  next();
});

export default router; 