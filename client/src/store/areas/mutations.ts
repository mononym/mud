import { MutationTree } from 'vuex';
import { AreasInterface } from './state';
import { AreaInterface } from '../area/state';
import Vue from 'vue';

function buildIndexes(state: AreasInterface) {
  state.areasForMapIndex = {};

  for (const prop in state.areasMap) {
    if (state.areasMap.hasOwnProperty(prop)) {
      const areaId = prop;
      const area = state.areasMap[areaId];

      if (!state.areasForMapIndex.hasOwnProperty(area.mapId)) {
        Vue.set(state.areasForMapIndex, area.mapId, []);
      }

      state.areasForMapIndex[area.mapId].splice(0, 0, area.id);
    }
  }
}

const mutation: MutationTree<AreasInterface> = {
  putArea(state: AreasInterface, area: AreaInterface) {
    Vue.set(state.areasMap, area.id, area);

    buildIndexes(state);
  },
  putInternalAreasForMap(
    state: AreasInterface,
    payload: { areas: Record<string, AreaInterface>; mapId: string }
  ) {
    state.areasMap = { ...this.areasMap, ...payload.areas };

    buildIndexes(state);
  }
};

export default mutation;
