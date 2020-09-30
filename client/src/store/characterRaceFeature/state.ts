export interface CharacterRaceFeatureOptionInterface {
  id: string;
  condition: Record<string, unknown>;
  option: Record<string, unknown>;
}

export interface CharacterRaceFeatureInterface {
  id: string;
  name: string;
  type: string;
  options: string[];
  instance_id: string;
}

const state: CharacterRaceFeatureInterface = {
  id: '',
  name: '',
  type: 'select',
  options: [],
  instance_id: ''
};

export default state;
