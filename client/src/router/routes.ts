import { RouteConfig } from 'vue-router';

const routes: RouteConfig[] = [
  {
    path: '/',
    component: () => import('layouts/EmptyLayout.vue'),
    children: [{ path: '', component: () => import('pages/LandingPage.vue') }]
  },
  {
    path: '/authenticate',
    component: () => import('layouts/EmptyLayout.vue'),
    children: [
      { path: '', component: () => import('pages/AuthenticatePage.vue') }
    ]
  },
  {
    path: '/dashboard',
    component: () => import('layouts/MainLayout.vue'),
    children: [
      {
        path: '',
        component: () => import('pages/DashboardPage.vue'),
        meta: { requiresAuth: true }
      }
    ]
  },
  // {
  //   path: '/characters',
  //   component: () => import('layouts/AppLayout.vue'),
  //   children: [
  //     { path: '', component: () => import('pages/CharactersPage.vue') },
  //     {
  //       path: 'new',
  //       component: () => import('pages/CharacterCreationPage.vue')
  //     }
  //   ]
  // },

  // Always leave this as last one,
  // but you can also remove it
  {
    path: '*',
    component: () => import('pages/Error404.vue')
  }
];

export default routes;
