import { GetterTree } from 'vuex';
import { StateInterface } from '../index';
import { AuthInterface } from './state';

const getters: GetterTree<AuthInterface, StateInterface> = {
  getIsAuthenticated(context) {
    context.isAuthenticated;
  },
  getIsAuthenticating(context) {
    context.isAuthenticating;
  },
  getPlayerId(context) {
    context.playerId;
  }
};

export default getters;
