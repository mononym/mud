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
  putArea(state: BuilderInterface, area: AreaInterface) {
    Vue.set(state.areaIndex, area.id, state.areas.length);

    state.areas.push(area);
  },
  putSelectedArea(state: BuilderInterface, area: AreaInterface) {
    state.selectedArea = area;
  },
  updateArea(state: BuilderInterface, area: AreaInterface) {
    Vue.set(state.areas, state.areaIndex[area.id], area);
  },
  deleteArea(state: BuilderInterface) {
    state.areas.splice(state.areaIndex[state.selectedArea.id], 1);

    state.selectedArea = { ...areaState };
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
    Vue.set(state.links, state.linkIndex[link.id], link);
  },
  addLink(state: BuilderInterface, link: LinkInterface) {
    Vue.set(state.linkIndex, link.id, state.links.length);

    state.links.push(link);
  },
  putLinks(state: BuilderInterface, links: LinkInterface[]) {
    state.links = links;
    state.linkIndex = {};

    state.links.forEach((link, index) => {
      Vue.set(state.linkIndex, link.id, index);
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
