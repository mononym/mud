import { GetterTree } from 'vuex';
import { StateInterface } from '../index';
import { CharactersInterface } from './state';
import { CharacterInterface } from '../character/state';

const getters: GetterTree<CharactersInterface, StateInterface> = {
  getCharacterById(state: CharactersInterface, characterId: string) {
    return state.characters[characterId];
  },
  listByPlayerId(state: CharactersInterface, playerId: string) {
    return Object.values(state.characters).filter(function(character: CharacterInterface) {
      return character.player_id == playerId;
    })
  }
};

export default getters;
