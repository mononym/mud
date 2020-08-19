import { MutationTree } from 'vuex';
import { CharactersInterface } from './state';
import { CharacterInterface } from '../character/state';
import Vue from 'vue';

const mutation: MutationTree<CharactersInterface> = {
  putCharacter(state: CharactersInterface, character: CharacterInterface) {
    Vue.set(state.characters, character.id, character)
  },
  removeCharacterById(state: CharactersInterface, characterId: string) {
    Vue.delete(state.characters, characterId)
  }
};

export default mutation;
