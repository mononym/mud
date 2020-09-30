import { MutationTree } from 'vuex';
import { BuilderInterface } from './state';
import { AreaInterface } from '../area/state';
import { LinkInterface } from '../link/state';
import { MapInterface } from '../map/state';
import { InstanceInterface } from '../instance/state';
import Vue from 'vue';
import areaState from '../area/state';
import linkState from '../link/state';

const mutation: MutationTree<BuilderInterface> = {
  // Area stuff
  putIsAreaSelected(state: BuilderInterface, isIt: boolean) {
    state.isAreaSelected = isIt;
  },
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
  // Link stuff
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
  putIsLinkSelected(state: BuilderInterface, isIt: boolean) {
    state.isLinkSelected = isIt;
  },
  deleteLink(state: BuilderInterface) {
    state.links.splice(state.linkIndex[state.selectedLink.id], 1);

    state.selectedLink = { ...linkState };
    state.linkIndex = {};
    state.links.forEach((link, index) => {
      Vue.set(state.linkIndex, link.id, index);
    });
  },
  // Map stuff
  putIsMapSelected(state: BuilderInterface, isIt: boolean) {
    state.isMapSelected = isIt;
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
  },
  // Instance stuff
  putInstanceBeingBuilt(state: BuilderInterface, instanceId: string) {
    state.instanceBeingBuilt = instanceId;
  },
  putInstances(state: BuilderInterface, instances: InstanceInterface[]) {
    state.instances = instances;
    state.instanceIndex = {};

    state.instances.forEach((instance, index) => {
      Vue.set(state.instanceIndex, instance.slug, index);
    });
  }
};

export default mutation;
