import { createRouter, createWebHistory, RouteRecordRaw, NavigationGuardNext, RouteLocationNormalized } from 'vue-router';
import { useAuthStore } from '../stores/auth';

const routes: RouteRecordRaw[] = [
  {
    path: '/company-select',
    name: 'company-select',
    component: () => import('../pages/CompanySelect.vue'),
    meta: {
      requiresAuth: true,
      layout: 'blank'
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

  next();
});

export default router; 