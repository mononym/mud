import { CharacterInterface } from '../character/state';

export interface CharactersInterface {
  characters: Record<string, CharacterInterface>;
}

const state: CharactersInterface = {
  characters: {
    'sdfwafsdfsdf': {id: 'sdfwafsdfsdf', active: true, active_instance_id: 'prime', name: 'Khan', agility: 10, strength: 10, wisdom: 10, dexterity: 10, charisma: 10, constitution: 10, eye_color: 'brown', hair_color: 'brown', handedness: 'right', intelligence: 10, player_id: 'a1988498-9500-4b79-bcad-e76c19eb4469', reflexes: 10, race: 'Elf', stamina: 10, skin_color: 'brown', posture: 'standing'},
    'svsdefswefrsdf': {id: 'svsdefswefrsdf', active: true, active_instance_id: 'premium', name: 'Alvisar', agility: 10, strength: 10, wisdom: 10, dexterity: 10, charisma: 10, constitution: 10, eye_color: 'brown', hair_color: 'brown', handedness: 'left', intelligence: 10, player_id: 'a1988498-9500-4b79-bcad-e76c19eb4469', reflexes: 10, race: 'Human', stamina: 10, skin_color: 'alabaster', posture: 'kneeling'}
  }
};

export default state;
