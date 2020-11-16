import { GetterTree } from 'vuex';
import { StateInterface } from '../index';
import { MapsInterface } from './state';

const getters: GetterTree<MapsInterface, StateInterface> = {
  getMapById: (state: MapsInterface) => (mapId: string) => {
    return state.maps[state.mapIndex[mapId]]
  },
  listAll(state: MapsInterface) {
    return state.maps
  }
};

export default getters;
