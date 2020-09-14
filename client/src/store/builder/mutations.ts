import { MutationTree } from 'vuex';
import { BuilderInterface } from './state';
import { AreaInterface } from '../area/state';
import { MapInterface } from '../map/state';
import Vue from 'vue'
import { isObject } from 'util';

const mutation: MutationTree<BuilderInterface> = {
  putSelectedMapId(state: BuilderInterface, id: string) {
    state.selectedMapId = id
  },
  putSelectedAreaId(state: BuilderInterface, id: string) {
    state.selectedAreaId = id
  },
  putIsAreaUnderConstruction(state: BuilderInterface, isIt: boolean) {
    state.isAreaUnderConstruction = isIt
  },
  putAreaUnderConstruction(state: BuilderInterface, area: AreaInterface) {
    state.areaUnderConstruction = area
  },
  putArea(state: BuilderInterface, area: AreaInterface) {
    Vue.set(state.areaIndex, area.id, state.areas.length)

    state.areas.push(area)
  },
  deleteArea(state: BuilderInterface) {
    console.log('deleteArea')
    console.log(state.selectedAreaId)
    console.log(state.areaIndex)
    console.log(state.areas)
    const id = state.selectedAreaId
    state.areas.splice(state.areaIndex[state.selectedAreaId], 1)
    console.log(state.areas)
    
    state.selectedAreaId = ''
    state.areaIndex = {}
    state.areas.forEach((area, index) => {
      Vue.set(state.areaIndex, area.id, index)
    });
  },
  putAreas(state: BuilderInterface, areas: AreaInterface[]) {
    state.areas = areas
    state.areaIndex = {}

    state.areas.forEach((area, index) => {
      Vue.set(state.areaIndex, area.id, index)
    });
  },
  putMap(state: BuilderInterface, map: MapInterface) {
    Vue.set(state.mapIndex, map.id, state.maps.length)

    state.maps.push(map)
  },
  putMaps(state: BuilderInterface, maps: MapInterface[]) {
    state.maps = maps
    state.mapIndex = {}

    state.maps.forEach((map, index) => {
      Vue.set(state.mapIndex, map.id, index)
    });
  },
};

export default mutation;
