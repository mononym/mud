import { MutationTree } from 'vuex';
import { MapsInterface } from './state';
import { MapInterface } from '../map/state';
import Vue from 'vue'

const mutation: MutationTree<MapsInterface> = {
  putMap(state: MapsInterface, map: MapInterface) {
    if (state.mapIndex[map.id] != undefined) {
      Vue.set(state.maps, state.mapIndex[map.id], map);
    } else {
      Vue.set(state.mapIndex, map.id, state.maps.length);
  
      state.maps.push(map);
    }
  },
  putMaps(state: MapsInterface, maps: MapInterface[]) {
    Vue.set(state, 'maps', maps)
    state.mapIndex = {};

    state.maps.forEach((map, index) => {
      Vue.set(state.mapIndex, map.id, index);
    });
  },
  removeMap(state: MapsInterface, mapId: string) {
    state.maps.splice(state.mapIndex[mapId], 1);
    state.mapIndex = {};

    state.maps.forEach((map, index) => {
      Vue.set(state.mapIndex, map.id, index);
    });
  }
};

export default mutation;
