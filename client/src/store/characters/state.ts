import { CharacterInterface } from '../character/state';

export interface CharactersInterface {
  characters: CharacterInterface[];
  characterIndex: Record<string, number>;
}

const state: CharactersInterface = {
  characters: [],
  characterIndex: {}
};

export default state;
