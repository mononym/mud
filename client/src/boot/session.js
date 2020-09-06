// import something here
import axios from 'axios';
import { boot } from 'quasar/wrappers'

// "async" is optional;
// more info on params: https://quasar.dev/quasar-cli/cli-documentation/boot-files#Anatomy-of-a-boot-file
export default boot(async ({ app }) => {
  console.log('session')
  // something to do
  await axios
    .post('/authenticate/sync')
    .then(response => {
      app.store.commit('auth/setIsAuthenticating', false);
      app.store.commit('auth/setIsSynced', true);

      if (response.status == 200) {
        app.store.commit(
          'auth/setIsAuthenticated',
          response.data.authenticated
        );
        app.store.commit('auth/setPlayerId', response.data.player.id);
        return true;
      } else {
        app.store.commit('auth/setIsAuthenticated', false);
        app.store.commit('auth/setPlayerId', '');
        return false;
      }
    })
    .catch(function() {
      app.store.commit('auth/setIsAuthenticated', false);
      app.store.commit('auth/setIsAuthenticating', false);
      app.store.commit('auth/setPlayerId', '');
      return false;
    });

    return true;
});
