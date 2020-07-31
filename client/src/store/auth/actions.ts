import { ActionTree } from 'vuex';
import { StateInterface } from '../index';
import { AuthInterface } from './state';
import axios from 'axios';

const actions: ActionTree<AuthInterface, StateInterface> = {
  startAuthenticationViaEmail({ commit }, email: string) {
    commit('setIsAuthenticated', false);
    commit('setIsAuthenticating', true);

    return new Promise((resolve, reject) => {
      axios
        .post('/authenticate/email', {
          email: email
        })
        .then(
          response => {
            console.log(response);
            // http success, call the mutator and change something in state
            resolve(response); // Let the calling function know that http is done. You may send some data back
          },
          error => {
            console.log(error);
            // http failed, let the calling function know that action did not work out
            reject(error);
          }
        );
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
          dispatch('players/putPlayer', response.data)
            .then(function() {
              resolve(true);
            })
            .catch(function() {
              reject(false);
            });
        })
        .catch(function() {
          commit('setIsAuthenticated', false);
          commit('setIsAuthenticating', false);
          commit('setPlayerId', '');
          reject(false);
        });
    });
  },
  syncStatus({ commit, dispatch }) {
    return new Promise(resolve => {
      axios
        .post('/authenticate/sync')
        .then(response => {
          if (response.status == 200) {
            commit('setIsAuthenticating', false);
            commit('setIsAuthenticated', true);
            commit('setPlayerId', response.data.id);

            dispatch('players/putPlayer', response.data)
              .then(function() {
                resolve(true);
              })
              .catch(function() {
                resolve(false);
              });
          } else {
            commit('setIsAuthenticated', false);
            commit('setIsAuthenticating', false);
            commit('setPlayerId', '');
            resolve(false);
          }
        })
        .catch(function() {
          commit('setIsAuthenticated', false);
          commit('setIsAuthenticating', false);
          commit('setPlayerId', '');
          resolve(false);
        });
    });
  },
  checkIfAuthenticated({state}) {
    return new Promise((reject, resolve) => {
      if (state.isAuthenticated) {
        resolve(true);
      } else {
        reject(false);
      }
    });
  }
};

export default actions;
