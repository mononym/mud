import { MutationTree } from 'vuex';
import { MapsInterface } from './state';
import { MapInterface } from '../map/state';

const mutation: MutationTree<MapsInterface> = {
  putMap(state: MapsInterface, map: MapInterface) {
    console.log('putting map')
    console.log(map)
    console.log(state.mapsMap)
    state.mapsMap.set(map.id, map)
    state.mapsList = Array.from(state.mapsMap.values())
    console.log(state.mapsMap)
    console.log(state.mapsList)
  },
  putMaps(state: MapsInterface, maps: Map<string, MapInterface>) {
    console.log('putting maps')
    console.log(maps)
    state.mapsMap = maps;
    state.mapsList = Array.from(state.mapsMap.values())
  },
  setFetched(state: MapsInterface, fetched: boolean) {
    state.fetched = fetched;
  },
  removeMapById(state: MapsInterface, mapId: string) {
    state.mapsMap.delete(mapId)
    state.mapsList = Array.from(state.mapsMap.values())
  }
};

export default mutation;
