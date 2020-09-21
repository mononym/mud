import { MutationTree } from 'vuex';
import { CharactersInterface } from './state';
import { CharacterInterface } from '../character/state';
import Vue from 'vue';

const mutation: MutationTree<CharactersInterface> = {
  addCharacter(state: CharactersInterface, character: CharacterInterface) {
    Vue.set(state.characterIndex, character.id, state.characters.length);

    state.characters.push(character);
  },
  putCharacters(state: CharactersInterface, characters: CharacterInterface[]) {
    state.characters = characters;
    state.characterIndex = {};

    state.characters.forEach((character, index) => {
      Vue.set(state.characterIndex, character.id, index);
    });
  },
  removeCharacterById(state: CharactersInterface, characterId: string) {
    Vue.delete(state.characters, characterId)
  }
};

export default mutation;
