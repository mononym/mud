
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

const RaceState: RaceInterface = {
  id: '',
  adjective: '',
  description: '',
  features: [],
  plural: '',
  portrait: '',
  pronouns: [],
  singular: '',
  instance_id: '',
}

export {RaceState}

export interface RacesInterface {
  races: Map<string, RaceInterface>;
}

const state: RacesInterface = {
  races: new Map()
};

export default state;
