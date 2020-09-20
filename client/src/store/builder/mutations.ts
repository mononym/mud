import { MutationTree } from 'vuex';
import { BuilderInterface } from './state';
import { AreaInterface } from '../area/state';
import { LinkInterface } from '../link/state';
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
  putInternalArea(state: BuilderInterface, area: AreaInterface) {
    Vue.set(state.internalAreaIndex, area.id, state.internalAreas.length);

    state.internalAreas.push(area);
  },
  putExternalArea(state: BuilderInterface, area: AreaInterface) {
    Vue.set(state.internalAreaIndex, area.id, state.externalAreas.length);

    state.externalAreas.push(area);
  },
  putSelectedArea(state: BuilderInterface, area: AreaInterface) {
    state.selectedArea = area;
  },
  updateArea(state: BuilderInterface, area: AreaInterface) {
    Vue.set(state.internalAreas, state.internalAreaIndex[area.id], area);
  },
  deleteArea(state: BuilderInterface) {
    state.internalAreas.splice(
      state.internalAreaIndex[state.selectedArea.id],
      1
    );

    state.selectedArea = { ...areaState };
    state.internalAreaIndex = {};
    state.internalAreas.forEach((area, index) => {
      Vue.set(state.internalAreaIndex, area.id, index);
    });
  },
  putInternalAreas(state: BuilderInterface, areas: AreaInterface[]) {
    state.internalAreas = areas;
    state.internalAreaIndex = {};

    state.internalAreas.forEach((area, index) => {
      Vue.set(state.internalAreaIndex, area.id, index);
    });
  },
  putExternalAreas(state: BuilderInterface, areas: AreaInterface[]) {
    state.externalAreas = areas;
    state.externalAreaIndex = {};

    state.externalAreas.forEach((area, index) => {
      Vue.set(state.externalAreaIndex, area.id, index);
    });
  },
  putIsLinkUnderConstruction(state: BuilderInterface, isIt: boolean) {
    state.isLinkUnderConstruction = isIt;
  },
  putIsLinkUnderConstructionNew(state: BuilderInterface, isIt: boolean) {
    state.isLinkUnderConstructionNew = isIt;
  },
  putLinkUnderConstruction(state: BuilderInterface, link: LinkInterface) {
    state.linkUnderConstruction = link;
  },
  putSelectedLink(state: BuilderInterface, link: LinkInterface) {
    state.selectedLink = link;
  },
  updateLink(state: BuilderInterface, link: LinkInterface) {
    if (
      Object.prototype.hasOwnProperty.call(state.internalLinkIndex, link.id)
    ) {
      Vue.set(state.internalLinks, state.internalLinkIndex[link.id], link);
    } else {
      Vue.set(state.externalLinks, state.externalLinkIndex[link.id], link);
    }
  },
  // TODO: This function is going to need to deal with internal/external links and how to insert them
  addLink(state: BuilderInterface, link: LinkInterface) {
    Vue.set(state.internalLinkIndex, link.id, state.internalLinks.length);

    state.internalLinks.push(link);
  },
  putInternalLinks(state: BuilderInterface, links: LinkInterface[]) {
    state.internalLinks = links;
    state.internalLinkIndex = {};

    state.internalLinks.forEach((link, index) => {
      Vue.set(state.internalLinkIndex, link.id, index);
    });
  },
  putExternalLinks(state: BuilderInterface, links: LinkInterface[]) {
    state.externalLinks = links;
    state.externalLinkIndex = {};

    state.externalLinks.forEach((link, index) => {
      Vue.set(state.externalLinkIndex, link.id, index);
    });
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
  putSelectedMap(state: BuilderInterface, map: MapInterface) {
    state.selectedMap = map;
  },
  updateMap(state: BuilderInterface, map: MapInterface) {
    Vue.set(state.maps, state.mapIndex[map.id], map);
  },
  putMap(state: BuilderInterface, map: MapInterface) {
    Vue.set(state.mapIndex, map.id, state.maps.length);

    state.maps.push(map);
  },
  addMap(state: BuilderInterface, map: MapInterface) {
    Vue.set(state.mapIndex, map.id, state.maps.length);

    state.maps.push(map);
  },
  putMaps(state: BuilderInterface, maps: MapInterface[]) {
    state.maps = maps;
    state.mapIndex = {};

    state.maps.forEach((map, index) => {
      Vue.set(state.mapIndex, map.id, index);
    });
  },
  // UI stuff
  putBottomLeftPanel(state: BuilderInterface, panel: string) {
    state.bottomLeftPanel = panel;
  },
  putBottomRightPanel(state: BuilderInterface, panel: string) {
    state.bottomRightPanel = panel;
  }
};

export default mutation;
