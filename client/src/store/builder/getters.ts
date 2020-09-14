import { GetterTree } from 'vuex';
import { StateInterface } from '../index';
import { BuilderInterface } from './state';

const getters: GetterTree<BuilderInterface, StateInterface> = {
  selectedAreaId(state: BuilderInterface) {
    return state.selectedAreaId;
  },
  selectedMapId(state: BuilderInterface) {
    return state.selectedMapId;
  },
  selectedArea(state: BuilderInterface) {
    return state.areas[state.areaIndex[state.selectedAreaId]];
  },
  cloneSelectedArea(state: BuilderInterface) {
    return state.cloneSelectedArea;
  },
  selectedMap(state: BuilderInterface) {
    return state.maps[state.mapIndex[state.selectedMapId]];
  },
  areas(state: BuilderInterface) {
    return state.areas;
  },
  maps(state: BuilderInterface) {
    return state.maps;
  },
  isAreaSelected(state: BuilderInterface) {
    return state.selectedAreaId !== '';
  },
  isMapSelected(state: BuilderInterface) {
    return state.selectedMapId !== '';
  },
  isAreaUnderConstruction(state: BuilderInterface) {
    return state.isAreaUnderConstruction;
  },
  areaUnderConstruction(state: BuilderInterface) {
    return state.areaUnderConstruction;
  }
};

export default getters;
