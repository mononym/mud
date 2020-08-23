import { ActionTree } from 'vuex';
import { StateInterface } from '../index';
import { AuthInterface } from './state';
import axios from 'axios';

const actions: ActionTree<AuthInterface, StateInterface> = {
  start({ commit }) {
    return new Promise((resolve) => {
      commit('setIsAuthenticated', false);
      commit('setIsAuthenticating', true);
      commit('setPlayerId', '');

      resolve()
    });
  },
  failed({ commit }) {
    return new Promise((resolve) => {
      commit('setIsAuthenticated', false);
      commit('setIsAuthenticating', false);
      commit('setPlayerId', '');

      resolve()
    });
  },
  logout({ commit }) {
    return new Promise((resolve) => {
      commit('setIsAuthenticated', false);
      commit('setIsAuthenticating', false);
      commit('setPlayerId', '');

      resolve()
    });
  },
  succeeded({ commit }, playerId: string) {
    return new Promise((resolve) => {
      commit('setIsAuthenticated', true);
      commit('setIsAuthenticating', false);
      commit('setPlayerId', playerId);

      resolve()
    });
  },
  validateAuthenticationToken({ commit, dispatch }, token: string) {
    return new Promise((resolve, reject) => {
      axios
        .post('/authenticate/token', {
          token: token
        })
        .then(function(response) {
          commit('setIsAuthenticating', false);
          commit('setIsAuthenticated', true);
          commit('setPlayerId', response.data.id);
          dispatch('players/putPlayer', response.data, {root: true})
            .then(function() {
              resolve();
            })
            .catch(function() {
              reject();
            });
        })
        .catch(function() {
          commit('setIsAuthenticated', false);
          commit('setIsAuthenticating', false);
          commit('setPlayerId', '');
          reject();
        });
    });
  }//,
  // syncStatus({ commit, dispatch, state }) {
  //   return new Promise(resolve => {
  //     if (state.synced) {
  //       resolve(state.isAuthenticated)
  //     } else {
  //       axios
  //         .post('/authenticate/sync')
  //         .then(response => {
  //           // commit('setSynced', true);
  //           commit('setIsAuthenticating', false);

  //           if (response.status == 200) {
  //             commit('setIsAuthenticated', true);
  //             commit('setPlayerId', response.data.id);
  
  //             dispatch('players/putPlayer', response.data, {root: true})
  //               .then(function() {
  //                 resolve(true);
  //               })
  //               .catch(function() {
  //                 resolve(true);
  //               });
  //           } else {
  //             commit('setIsAuthenticating', false);
  //             commit('setPlayerId', '');
  //             resolve(false);
  //           }
  //         })
  //         .catch(function() {
  //           commit('setSynced', true);
  //           commit('setIsAuthenticated', false);
  //           commit('setIsAuthenticating', false);
  //           commit('setPlayerId', '');
  //           resolve(false);
  //         });
  //     }
  //   });
  // }
};

export default actions;
