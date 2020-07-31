import { ActionTree } from 'vuex';
import { StateInterface } from '../index';
import { PlayersInterface } from './state';
import { PlayerInterface } from '../player/state';

const actions: ActionTree<PlayersInterface, StateInterface> = {
  putPlayer({ commit }, player: PlayerInterface) {
    commit('putPlayer', player);
  },
  removePlayerById({ commit }, playerId: string) {
    commit('removePlayer', playerId);
  }
};

export default actions;
