// import something here

// "async" is optional;
// more info on params: https://quasar.dev/quasar-cli/cli-documentation/boot-files#Anatomy-of-a-boot-file
export default ({ router, store }) => {
  // something to do
  router.beforeEach((to, from, next) => {
    console.log('before route');
    if (to.matched.some(record => record.meta.requiresAuth)) {
      console.log('requires auth');
      if (store.getters['auth/getIsAuthenticated']) {
        next();
      } else {
        next({
          path: '/login',
          query: { redirect: to.fullPath }
        });
      }
    } else if (to.matched.some(record => record.meta.requiresNoAuth)) {
      console.log('requires no auth');

      if (store.getters['auth/getIsAuthenticated']) {
        next({
          path: '/dashboard'
        });
      } else {
        next()
      }
    } else {
      console.log('no auth check');
      next(); // make sure to always call next()!
    }
  })
}
