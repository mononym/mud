export interface CharacterInterface {
  id: string;
  name: string,
  active: boolean;
  active_instance_id: string;
  agility: number;
  charisma: number;
  constitution: number;
  dexterity: number;
  intelligence: number;
  reflexes: number;
  stamina: number;
  strength: number;
  wisdom: number;
  eye_color: string;
  hair_color: string;
  race: string;
  skin_color: string;
  handedness: string;
  posture: string;
  player_id: string;
}

const state: CharacterInterface = {
  id: '',
  name: '',
  active: false,
  active_instance_id: '',
  agility: 0,
  charisma: 0,
  constitution: 0,
  dexterity: 0,
  intelligence: 0,
  reflexes: 0,
  stamina: 0,
  strength: 0,
  wisdom: 0,
  eye_color: '',
  hair_color: '',
  race: '',
  skin_color: '',
  handedness: '',
  posture: '',
  player_id: ''
};

export default state;
