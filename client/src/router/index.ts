import { route } from 'quasar/wrappers';
import VueRouter from 'vue-router';
import { Store } from 'vuex';
import { StateInterface } from '../store';
import routes from './routes';

/*
 * If not building with SSR mode, you can
 * directly export the Router instantiation
 */

export default route<Store<StateInterface>>(function({ store, Vue }) {
  Vue.use(VueRouter);

  const Router = new VueRouter({
    scrollBehavior: () => ({ x: 0, y: 0 }),
    routes,

    // Leave these as is and change from quasar.conf.js instead!
    // quasar.conf.js -> build -> vueRouterMode
    // quasar.conf.js -> build -> publicPath
    mode: process.env.VUE_ROUTER_MODE,
    base: process.env.VUE_ROUTER_BASE
  });

  Router.beforeEach((to, from, next) => {
    console.log('before route');
    console.log(store);

    // console.log(store.getters.auth);
    // console.log(store.getters['get auth/getIsAuthenticated']);
    // console.log(store.getters['auth/getIsAuthenticated']);
    if (to.matched.some(record => record.meta.requiresAuth)) {
      console.log('requires auth');
      store
        .dispatch('auth/checkIfAuthenticated')
        .then(() => next())
        .catch(() =>
          next({
            path: '/login',
            query: { redirect: to.fullPath }
          })
        );
      // this route requires auth, check if logged in
      // if not, redirect to login page.
      // if (!store.getters['auth/getIsAuthenticated']()) {
      //   next({
      //     path: '/login',
      //     query: { redirect: to.fullPath }
      //   });
      // } else {
      // }
    } else {
      console.log('no auth required');
      next(); // make sure to always call next()!
    }
  });

  return Router;
});
