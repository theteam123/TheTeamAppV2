import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'
import Home from './pages/Home.vue'
import Auth from './pages/Auth.vue'
import Users from './pages/Users.vue'
import Companies from './pages/Companies.vue'
import Roles from './pages/Roles.vue'
import Tags from './pages/Tags.vue'
import MenuSections from './pages/MenuSections.vue'
import Content from './pages/Content.vue'
import EmployeeFeedbackRecords from './pages/EmployeeFeedbackRecords.vue'

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
    path: '/users',
    name: 'users',
    component: Users,
    meta: { requiresAuth: true }
  },
  {
    path: '/companies',
    name: 'companies',
    component: Companies,
    meta: { requiresAuth: true }
  },
  {
    path: '/roles',
    name: 'roles',
    component: Roles,
    meta: { requiresAuth: true }
  },
  {
    path: '/tags',
    name: 'tags',
    component: Tags,
    meta: { requiresAuth: true }
  },
  {
    path: '/menu-sections',
    name: 'menu-sections',
    component: MenuSections,
    meta: { requiresAuth: true }
  },
  {
    path: '/content',
    name: 'content',
    component: Content,
    meta: { requiresAuth: true }
  },
  {
    path: '/feedback-records',
    name: 'feedback-records',
    component: EmployeeFeedbackRecords,
    meta: { requiresAuth: true }
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

// Add debug logging
router.beforeEach((to, from, next) => {
  console.log('Route navigation:', {
    to: to.fullPath,
    from: from.fullPath,
    toName: to.name,
    fromName: from.name,
    availableRoutes: router.getRoutes().map(r => ({
      path: r.path,
      name: r.name
    }))
  })
  next()
})

export default router