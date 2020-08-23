import { MutationTree } from 'vuex';
import { AuthInterface } from './state';

const mutation: MutationTree<AuthInterface> = {
  setIsAuthenticated(state: AuthInterface, isAuthenticated: boolean) {
    state.isAuthenticated = isAuthenticated;
  },
  setIsAuthenticating(state: AuthInterface, isAuthenticating: boolean) {
    state.isAuthenticating = isAuthenticating;
  },
  setPlayerId(state: AuthInterface, playerId: string) {
    state.playerId = playerId;
  },
  setIsSynced(state: AuthInterface, synced: boolean) {
    state.isSynced = synced;
  }
};

export default mutation;
