import { RouteConfig } from 'vue-router';

const routes: RouteConfig[] = [
  {
    path: '/',
    component: () => import('layouts/EmptyLayout.vue'),
    children: [
      { path: '', name: 'home', component: () => import('pages/LandingPage.vue'), meta: { requiresNoAuth: true } },
      { path: 'login', name: 'login', component: () => import('pages/LandingPage.vue'), meta: { requiresNoAuth: true } },
      { path: 'authenticate', name: 'authenticate', component: () => import('pages/AuthenticatePage.vue'), meta: { requiresNoAuth: true } }
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
      },
      {
        path: 'new',
        component: () => import('pages/CharacterCreationPage.vue'),
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
