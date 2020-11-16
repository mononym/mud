import { MutationTree } from 'vuex';
import { AreasInterface } from './state';
import { AreaInterface } from '../area/state';
import Vue from 'vue';

const mutation: MutationTree<AreasInterface> = {
  putArea(state: AreasInterface, area: AreaInterface) {
    if (state.areaIndex[area.id] != undefined) {
      Vue.set(state.areas, state.areaIndex[area.id], area);
    } else {
      Vue.set(state.areaIndex, area.id, state.areas.length);
  
      state.areas.push(area);
    }
  },
  putAreas(state: AreasInterface, areas: AreaInterface[]) {
    state.areas = areas;
    state.areaIndex = {};

    state.areas.forEach((area, index) => {
      Vue.set(state.areaIndex, area.id, index);
    });
  },
  removeArea(state: AreasInterface, areaId: string) {
    state.areas.splice(state.areaIndex[areaId], 1);
    state.areaIndex = {};

    state.areas.forEach((area, index) => {
      Vue.set(state.areaIndex, area.id, index);
    });
  }
};

export default mutation;
