import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'
import Home from './pages/Home.vue'
import Auth from './pages/Auth.vue'
import { useAuthStore } from './stores/auth'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    name: 'home',
    component: Home,
    meta: { requiresAuth: true }
  },
  {
    path: '/auth',
    name: 'auth',
    component: Auth,
    meta: { requiresAuth: false }
  },
  {
    path: '/admin/debug',
    name: 'debug',
    component: () => import('./pages/admin/Debug.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/admin/users',
    name: 'users',
    component: () => import('./pages/admin/Users.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/admin/roles',
    name: 'roles',
    component: () => import('./pages/admin/Roles.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/admin/content-tags',
    name: 'content-tags',
    component: () => import('./pages/admin/Tags.vue'),
    meta: {
      requiresAuth: true,
      requiresPermission: 'content.manage'
    }
  },
  {
    path: '/admin/menu-sections',
    name: 'menu-sections',
    component: () => import('./pages/admin/MenuSections.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/admin/content',
    name: 'content',
    component: () => import('./pages/admin/Content.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/admin/companies',
    name: 'admin-companies',
    component: () => import('./pages/admin/Companies.vue'),
    meta: {
      requiresAuth: true,
      requiredPermission: 'companies.view'
    }
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'not-found',
    redirect: '/'
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router