import { GetterTree } from 'vuex';
import { StateInterface } from '../index';
import { RaceInterface, RacesInterface } from './state';

const getters: GetterTree<RacesInterface, StateInterface> = {
    allArray(state: RacesInterface): RaceInterface[] {
      return Array.from(state.races.values())
    },
    allMap(state: RacesInterface): Map<string, RaceInterface> {
      return state.races
    }
  };

export default getters;
