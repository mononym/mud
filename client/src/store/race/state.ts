
import { CharacterRaceFeatureInterface } from '../characterRaceFeature/state';

export interface RaceInterface {
  id: string;
  adjective: string;
  description: string;
  features: CharacterRaceFeatureInterface[];
  plural: string;
  portrait: string;
  pronouns: string[];
  singular: string;
  instance_id: string;
}

const state: RaceInterface = {
  id: '',
  adjective: '',
  description: '',
  features: [],
  plural: '',
  portrait: '',
  pronouns: [],
  singular: '',
  instance_id: '',
};

export default state;
