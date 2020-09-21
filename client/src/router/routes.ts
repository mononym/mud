import { RouteConfig } from 'vue-router';

const routes: RouteConfig[] = [
  {
    path: '/',
    component: () => import('layouts/EmptyLayout.vue'),
    children: [
      {
        path: '',
        name: 'home',
        component: () => import('pages/LandingPage.vue'),
        meta: { requiresNoAuth: true }
      },
      {
        path: 'login',
        name: 'login',
        component: () => import('pages/LandingPage.vue'),
        meta: { requiresNoAuth: true }
      },
      {
        path: 'authenticate',
        name: 'authenticate',
        component: () => import('pages/AuthenticatePage.vue'),
        meta: { requiresNoAuth: true }
      }
    ]
  },
  {
    path: '/',
    component: () => import('layouts/MainLayout.vue'),
    children: [
      {
        path: 'dashboard',
        component: () => import('pages/DashboardPage.vue'),
        meta: { requiresAuth: true }
      }
    ]
  },
  {
    path: '/characters',
    component: () => import('layouts/MainLayout.vue'),
    children: [
      // { path: '', component: () => import('pages/CharactersPage.vue') },
      {
        path: 'new',
        component: () => import('pages/CharacterCreationPage.vue'),
        meta: { requiresAuth: true }
      }
    ]
  },
  {
    path: '/build',
    component: () => import('layouts/MainLayout.vue'),
    children: [
      {
        path: '',
        component: () => import('pages/BuildDashboardPage.vue'),
        meta: { requiresAuth: true }
      },
      // {
      //   path: 'instance/new',
      //   component: () => import('pages/NewInstancePage.vue'),
      //   meta: { requiresAuth: true }
      // },
      {
        path: ':instance',
        component: () => import('pages/BuildInstancePage.vue'),
        meta: { requiresAuth: true }
      }
      // {
      //   path: ':instance/region/:region/edit',
      //   component: () => import('pages/BuildInstancePage.vue'),
      //   meta: { requiresAuth: true }
      // },
      // {
      //   path: ':instance/region/:region/build',
      //   component: () => import('pages/BuildRegionPage.vue'),
      //   meta: { requiresAuth: true }
      // },
    ]
  },
  {
    path: '/play',
    component: () => import('layouts/GameClientLayout.vue'),
    children: [
      {
        path: ':slug',
        component: () => import('pages/GameClientPage.vue'),
        meta: { requiresAuth: true }
      }
    ]
  },

  // Always leave this as last one,
  // but you can also remove it
  {
    path: '*',
    component: () => import('pages/Error404.vue')
  }
];

export default routes;
