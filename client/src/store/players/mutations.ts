import { MutationTree } from 'vuex';
import { PlayersInterface } from './state';
import { PlayerInterface } from '../player/state';

const mutation: MutationTree<PlayersInterface> = {
  putPlayer(state: PlayersInterface, player: PlayerInterface) {
    state.players.set(player.id, player);
  },
  removePlayerById(state: PlayersInterface, playerId: string) {
    state.players.delete(playerId);
  }
};

export default mutation;
