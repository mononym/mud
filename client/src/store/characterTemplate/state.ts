import { CharacterRaceFeatureInterface } from '../characterRaceFeature/state'

export interface CharacterTemplateInterface {
  id: string;
  name: string;
  description: string;
  template: string;
  instance_id: string;
  features: CharacterRaceFeatureInterface[];
}

const state: CharacterTemplateInterface = {
  id: '',
  description: '',
  template: '',
  name: '',
  features: [],
  instance_id: ''
};

export default state;
