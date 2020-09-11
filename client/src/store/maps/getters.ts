import { GetterTree } from 'vuex';
import { StateInterface } from '../index';
import { MapsInterface } from './state';

const getters: GetterTree<MapsInterface, StateInterface> = {
  getMapById(state: MapsInterface, mapId: string) {
    state.maps.get(mapId);
  }
};

export default getters;
