import { GetterTree } from 'vuex';
import { AreaInterface } from '../area/state';
import { StateInterface } from '../index';
import { LinkInterface } from '../link/state';
import { MapInterface } from '../map/state';
import { BuilderInterface } from './state';
import areaState from '../area/state';
import linkState from '../link/state';
import mapState from '../map/state';

const getters: GetterTree<BuilderInterface, StateInterface> = {
  areaIndex(state: BuilderInterface): Record<string, number> {
    return state.areaIndex;
  },
  selectedAreaId(state: BuilderInterface): string {
    return state.selectedArea.id;
  },
  selectedArea(state: BuilderInterface): AreaInterface {
    return state.selectedArea;
  },
  areas(state: BuilderInterface): AreaInterface[] {
    return state.areas;
  },
  isAreaSelected(state: BuilderInterface): boolean {
    return state.isAreaSelected;
  },
  workingArea(state: BuilderInterface): AreaInterface {
    if (state.isAreaUnderConstruction) {
      return state.areaUnderConstruction;
    } else if (state.isAreaSelected) {
      return state.selectedArea;
    } else {
      return { ...areaState };
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
  links(state: BuilderInterface): LinkInterface[] {
    return state.links;
  },
  workingAreaLinks(state: BuilderInterface): LinkInterface[] {
    let workingArea: AreaInterface;
    if (state.isAreaUnderConstruction) {
      workingArea = state.areaUnderConstruction;
    } else {
      workingArea = state.selectedArea;
    }

    return state.links.filter(
      link => link.toId == workingArea.id || link.fromId == workingArea.id
    );
  },
  isLinkSelected(state: BuilderInterface): boolean {
    return state.isLinkSelected
  },
  workingLink(state: BuilderInterface): LinkInterface {
    let link: LinkInterface;
    if (state.isLinkUnderConstruction) {
      link = state.linkUnderConstruction;
    } else if (state.isLinkSelected) {
      link = state.selectedLink;
    } else {
      link = { ...linkState };
    }

    if (link.toId !== '' && link.fromId !== '') {
      link.toName = state.areas[state.areaIndex[link.toId]].name;
      link.fromName = state.areas[state.areaIndex[link.fromId]].name;
    }

    return link;
  },
  workingLinkToArea(state: BuilderInterface): AreaInterface {
    let link: LinkInterface;

    if (state.isLinkUnderConstruction) {
      link = state.linkUnderConstruction;
    } else {
      link = state.selectedLink;
    }

    if (link.id == '') {
      return { ...areaState };
    } else {
      const toId: string = link.toId;

      return state.areas[state.areaIndex[toId]];
    }
  },
  workingLinkFromArea(state: BuilderInterface): AreaInterface {
    let link: LinkInterface;

    if (state.isLinkUnderConstruction) {
      link = state.linkUnderConstruction;
    } else {
      link = state.selectedLink;
    }

    if (link.id == '') {
      return { ...areaState };
    } else {
      const fromId: string = link.fromId;

      return state.areas[state.areaIndex[fromId]];
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
    return state.isMapSelected;
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
    } else if (state.isMapSelected) {
      return state.selectedMap;
    } else {
      return { ...mapState };
    }
  },
  // UI stuff
  bottomLeftPanel(state: BuilderInterface): string {
    return state.bottomLeftPanel;
  },
  bottomRightPanel(state: BuilderInterface): string {
    return state.bottomRightPanel;
  }
};

export default getters;
