import { MutationTree } from 'vuex';
import { MapsInterface } from './state';
import { MapInterface } from '../map/state';
import Vue from 'vue';

const mutation: MutationTree<MapsInterface> = {
  putMap(state: MapsInterface, map: MapInterface) {
    Vue.set(state.maps, map.id, map);
  },
  putMaps(state: MapsInterface, maps: Map<string, MapInterface>) {
    console.log('putting maps')
    console.log(maps)
    state.maps = maps;
  },
  setFetched(state: MapsInterface, fetched: boolean) {
    state.fetched = fetched;
  },
  removeMapById(state: MapsInterface, mapId: string) {
    Vue.delete(state.maps, mapId);
  }
};

export default mutation;
