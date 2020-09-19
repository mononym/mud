import { GetterTree } from 'vuex';
import { AreaInterface } from '../area/state';
import { StateInterface } from '../index';
import { LinkInterface } from '../link/state';
import { MapInterface } from '../map/state';
import { BuilderInterface } from './state';

const getters: GetterTree<BuilderInterface, StateInterface> = {
  selectedAreaId(state: BuilderInterface): string {
    return state.selectedArea.id;
  },
  selectedArea(state: BuilderInterface): AreaInterface {
    return state.selectedArea;
  },
  internalAreas(state: BuilderInterface): AreaInterface[] {
    return state.internalAreas;
  },
  externalAreas(state: BuilderInterface): AreaInterface[] {
    return state.externalAreas;
  },
  allAreas(state: BuilderInterface): AreaInterface[] {
    return state.internalAreas.concat(state.externalAreas);
  },
  isAreaSelected(state: BuilderInterface): boolean {
    return state.selectedArea.id !== '';
  },
  workingArea(state: BuilderInterface): AreaInterface {
    if (state.isAreaUnderConstruction) {
      return state.areaUnderConstruction;
    } else {
      return state.selectedArea;
    }
  },
  isAreaUnderConstruction(state: BuilderInterface): boolean {
    return state.isAreaUnderConstruction;
  },
  isAreaUnderConstructionNew(state: BuilderInterface): boolean {
    return state.isAreaUnderConstructionNew;
  },
  areaUnderConstruction(state: BuilderInterface): AreaInterface {
    return state.areaUnderConstruction;
  },
  internalLinks(state: BuilderInterface): LinkInterface[] {
    return state.internalLinks;
  },
  externalLinks(state: BuilderInterface): LinkInterface[] {
    return state.externalLinks;
  },
  allLinks(state: BuilderInterface): LinkInterface[] {
    return state.internalLinks.concat(state.externalLinks);
  },
  workingAreaLinks(state: BuilderInterface): LinkInterface[] {
    let workingArea: AreaInterface;
    if (state.isAreaUnderConstruction) {
      workingArea = state.areaUnderConstruction;
    } else {
      workingArea = state.selectedArea;
    }

    const someLinks = state.internalLinks.filter(
      link => link.toId == workingArea.id || link.fromId == workingArea.id
    );

    const moreLinks = state.externalLinks.filter(
      link => link.toId == workingArea.id || link.fromId == workingArea.id
    );

    return someLinks.concat(moreLinks);
  },
  isLinkSelected(state: BuilderInterface): boolean {
    return state.selectedLink.id !== '';
  },
  workingLink(state: BuilderInterface): LinkInterface {
    if (state.isLinkUnderConstruction) {
      return state.linkUnderConstruction;
    } else {
      return state.selectedLink;
    }
  },
  selectedLink(state: BuilderInterface): LinkInterface {
    return state.selectedLink;
  },
  isLinkUnderConstruction(state: BuilderInterface): boolean {
    return state.isLinkUnderConstruction;
  },
  isLinkUnderConstructionNew(state: BuilderInterface): boolean {
    return state.isLinkUnderConstructionNew;
  },
  linkUnderConstruction(state: BuilderInterface): LinkInterface {
    return state.linkUnderConstruction;
  },
  maps(state: BuilderInterface): MapInterface[] {
    return state.maps;
  },
  selectedMap(state: BuilderInterface): MapInterface {
    return state.selectedMap;
  },
  selectedMapId(state: BuilderInterface): string {
    return state.selectedMap.id;
  },
  isMapSelected(state: BuilderInterface): boolean {
    return state.selectedMap.id !== '';
  },
  isMapUnderConstruction(state: BuilderInterface): boolean {
    return state.isMapUnderConstruction;
  },
  isMapUnderConstructionNew(state: BuilderInterface): boolean {
    return state.isMapUnderConstructionNew;
  },
  mapUnderConstruction(state: BuilderInterface): MapInterface {
    return state.mapUnderConstruction;
  },
  workingMap(state: BuilderInterface): MapInterface {
    if (state.isMapUnderConstruction) {
      return state.mapUnderConstruction;
    } else {
      return state.selectedMap;
    }
  }
};

export default getters;
