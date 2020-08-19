import { ActionTree } from 'vuex';
import { StateInterface } from '../index';
import { CharactersInterface } from './state';
import { CharacterInterface } from '../character/state';

const actions: ActionTree<CharactersInterface, StateInterface> = {
  putCharacter({ commit }, character: CharacterInterface) {
    commit('putCharacter', character);
  },
  removeCharacterById({ commit }, characterId: string) {
    commit('removeCharacter', characterId);
  }
};

export default actions;
