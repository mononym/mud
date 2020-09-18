import { GetterTree } from 'vuex';
import { StateInterface } from '../index';
import { BuilderInterface } from './state';

const getters: GetterTree<BuilderInterface, StateInterface> = {
  selectedAreaId(state: BuilderInterface) {
    return state.selectedArea.id;
  },
  selectedArea(state: BuilderInterface) {
    return state.selectedArea;
  },
  internalAreas(state: BuilderInterface) {
    return state.internalAreas;
  },
  externalAreas(state: BuilderInterface) {
    return state.externalAreas;
  },
  allAreas(state: BuilderInterface) {
    return state.internalAreas.concat(state.externalAreas);
  },
  isAreaSelected(state: BuilderInterface) {
    return state.selectedArea.id !== '';
  },
  workingArea(state: BuilderInterface) {
    if (state.isAreaUnderConstruction) {
      return state.areaUnderConstruction;
    } else {
      return state.selectedArea;
    }
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
  internalLinks(state: BuilderInterface) {
    return state.internalLinks;
  },
  externalLinks(state: BuilderInterface) {
    return state.externalLinks;
  },
  allLinks(state: BuilderInterface) {
    return state.internalLinks.concat(state.externalLinks);
  },
  isLinkSelected(state: BuilderInterface) {
    return state.selectedLink.id !== '';
  },
  workingLink(state: BuilderInterface) {
    if (state.isLinkUnderConstruction) {
      return state.linkUnderConstruction;
    } else {
      return state.selectedLink;
    }
  },
  selectedLink(state: BuilderInterface) {
    return state.selectedLink;
  },
  isLinkUnderConstruction(state: BuilderInterface) {
    return state.isLinkUnderConstruction;
  },
  isLinkUnderConstructionNew(state: BuilderInterface) {
    return state.isLinkUnderConstructionNew;
  },
  linkUnderConstruction(state: BuilderInterface) {
    return state.linkUnderConstruction;
  },
  maps(state: BuilderInterface) {
    return state.maps;
  },
  selectedMap(state: BuilderInterface) {
    return state.selectedMap;
  },
  selectedMapId(state: BuilderInterface) {
    return state.selectedMap.id;
  },
  isMapSelected(state: BuilderInterface) {
    return state.selectedMap.id !== '';
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
  workingMap(state: BuilderInterface) {
    if (state.isMapUnderConstruction) {
      return state.mapUnderConstruction;
    } else {
      return state.selectedMap;
    }
  }
};

export default getters;
