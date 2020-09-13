import { GetterTree } from 'vuex';
import { StateInterface } from '../index';
import { MapsInterface } from './state';

const getters: GetterTree<MapsInterface, StateInterface> = {
  getMapById: (state: MapsInterface) => (mapId: string) => {
    return state.mapsMap.get(mapId)
  },
  listAll(state: MapsInterface) {
    return state.mapsList
  }
};

export default getters;
