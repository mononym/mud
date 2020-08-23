import { GetterTree } from 'vuex';
import { StateInterface } from '../index';
import { AuthInterface } from './state';

const getters: GetterTree<AuthInterface, StateInterface> = {
  getIsAuthenticated(state) {
    return state.isAuthenticated;
  },
  getIsAuthenticating(state) {
    return state.isAuthenticating;
  },
  getIsSynced(state) {
    return state.isSynced;
  },
  getPlayerId(state) {
    return state.playerId;
  }
};

export default getters;
