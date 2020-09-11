import { MutationTree } from 'vuex';
import { MapsInterface } from './state';
import { MapInterface } from '../map/state';

const mutation: MutationTree<MapsInterface> = {
  putMap(state: MapsInterface, map: MapInterface) {
    state.maps.set(map.id, map);
  },
  removeMapById(state: MapsInterface, mapId: string) {
    state.maps.delete(mapId);
  }
};

export default mutation;
