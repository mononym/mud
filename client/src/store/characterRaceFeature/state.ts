export interface CharacterRaceFeatureOptionConditionInterface {
  id: string;
  key: string;
  comparison: string;
  values: string[];
}

const ConditionState: CharacterRaceFeatureOptionConditionInterface = {
  id: '',
  key: '',
  comparison: '',
  values: []
}

export {ConditionState}

export interface CharacterRaceFeatureOptionInterface {
  id: string;
  min: number;
  max: number;
  value: string;
  toggle: boolean
  conditions: CharacterRaceFeatureOptionConditionInterface[];
}

const OptionState: CharacterRaceFeatureOptionInterface = {
  id: '',
  min: 0,
  max: 0,
  value: '',
  toggle: false,
  conditions: []
}

export {OptionState}

export interface CharacterRaceFeatureInterface {
  id: string;
  name: string;
  field: string;
  key: string;
  type: string;
  options: CharacterRaceFeatureOptionInterface[];
  instance_id: string;
}

const state: CharacterRaceFeatureInterface = {
  id: '',
  field: '',
  key: '',
  name: '',
  type: 'select',
  options: [],
  instance_id: ''
};

export default state;
