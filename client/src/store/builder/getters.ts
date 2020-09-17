import { GetterTree } from 'vuex';
import { StateInterface } from '../index';
import { BuilderInterface } from './state';

const getters: GetterTree<BuilderInterface, StateInterface> = {
  selectedAreaId(state: BuilderInterface) {
    return state.selectedArea.id;
  },
  selectedMapId(state: BuilderInterface) {
    return state.selectedMap.id;
  },
  selectedArea(state: BuilderInterface) {
    return state.selectedArea;
  },
  selectedMap(state: BuilderInterface) {
    return state.selectedMap;
  },
  internalAreas(state: BuilderInterface) {
    return state.internalAreas;
  },
  externalAreas(state: BuilderInterface) {
    return state.externalAreas;
  },
  maps(state: BuilderInterface) {
    return state.maps;
  },
  links(state: BuilderInterface) {
    return state.links;
  },
  allAreas(state: BuilderInterface) {
    return state.internalAreas.concat(state.externalAreas);
  },
  isAreaSelected(state: BuilderInterface) {
    return state.selectedArea.id !== '';
  },
  isMapSelected(state: BuilderInterface) {
    return state.selectedMap.id !== '';
  },
  isAreaUnderConstruction(state: BuilderInterface) {
    return state.isAreaUnderConstruction;
  },
  isAreaUnderConstructionNew(state: BuilderInterface) {
    return state.isAreaUnderConstructionNew;
  },
  areaUnderConstruction(state: BuilderInterface) {
    return state.areaUnderConstruction;
  },
  isMapUnderConstruction(state: BuilderInterface) {
    return state.isMapUnderConstruction;
  },
  isMapUnderConstructionNew(state: BuilderInterface) {
    return state.isMapUnderConstructionNew;
  },
  mapUnderConstruction(state: BuilderInterface) {
    return state.mapUnderConstruction;
  },
  workingArea(state: BuilderInterface) {
    if (state.isAreaUnderConstruction) {
      return state.areaUnderConstruction;
    } else {
      return state.selectedArea;
    }
  },
  workingMap(state: BuilderInterface) {
    if (state.isMapUnderConstruction) {
      return state.mapUnderConstruction;
    } else {
      return state.selectedMap;
    }
  }
};

export default getters;
