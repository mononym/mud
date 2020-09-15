import { MutationTree } from 'vuex';
import { BuilderInterface } from './state';
import { AreaInterface } from '../area/state';
import { MapInterface } from '../map/state';
import Vue from 'vue';
import areaState from '../area/state';

const mutation: MutationTree<BuilderInterface> = {
  putIsAreaUnderConstruction(state: BuilderInterface, isIt: boolean) {
    state.isAreaUnderConstruction = isIt;
  },
  putIsAreaUnderConstructionNew(state: BuilderInterface, isIt: boolean) {
    state.isAreaUnderConstructionNew = isIt;
  },
  putAreaUnderConstruction(state: BuilderInterface, area: AreaInterface) {
    state.areaUnderConstruction = area;
  },
  putArea(state: BuilderInterface, area: AreaInterface) {
    Vue.set(state.areaIndex, area.id, state.areas.length);

    state.areas.push(area);
  },
  putIsMapUnderConstruction(state: BuilderInterface, isIt: boolean) {
    state.isMapUnderConstruction = isIt;
  },
  putIsMapUnderConstructionNew(state: BuilderInterface, isIt: boolean) {
    state.isMapUnderConstructionNew = isIt;
  },
  putMapUnderConstruction(state: BuilderInterface, map: MapInterface) {
    state.mapUnderConstruction = map;
  },
  putSelectedMap(state: BuilderInterface, mapId: string) {
    Vue.set(state, 'selectedMap', state.maps[state.mapIndex[mapId]])
  },
  putSelectedArea(state: BuilderInterface, areaId: string) {
    Vue.set(state, 'selectedArea', state.areas[state.areaIndex[areaId]])
  },
  updateArea(state: BuilderInterface, area: AreaInterface) {
    Vue.set(state.areas, state.areaIndex[area.id], area);
  },
  deleteArea(state: BuilderInterface) {
    state.areas.splice(state.areaIndex[state.selectedArea.id], 1);

    state.selectedArea = {...areaState};
    state.areaIndex = {};
    state.areas.forEach((area, index) => {
      Vue.set(state.areaIndex, area.id, index);
    });
  },
  putAreas(state: BuilderInterface, areas: AreaInterface[]) {
    state.areas = areas;
    state.areaIndex = {};

    state.areas.forEach((area, index) => {
      Vue.set(state.areaIndex, area.id, index);
    });
  },
  putMap(state: BuilderInterface, map: MapInterface) {
    Vue.set(state.mapIndex, map.id, state.maps.length);

    state.maps.push(map);
  },
  putMaps(state: BuilderInterface, maps: MapInterface[]) {
    state.maps = maps;
    state.mapIndex = {};

    state.maps.forEach((map, index) => {
      Vue.set(state.mapIndex, map.id, index);
    });
  }
};

export default mutation;
