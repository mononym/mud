import { GetterTree } from 'vuex';
import { StateInterface } from '../index';
import { PlayersInterface } from './state';

const getters: GetterTree<PlayersInterface, StateInterface> = {
  getPlayerById(state: PlayersInterface, playerId: string) {
    state.players.get(playerId);
  }
};

export default getters;
