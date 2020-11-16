import { GetterTree } from 'vuex';
import { StateInterface } from '../index';
import { InstancesInterface } from './state';

const getters: GetterTree<InstancesInterface, StateInterface> = {
  instanceBeingBuilt(state: InstancesInterface) {
    const index = state.instanceSlugIndex[state.instanceBeingBuilt]

    if (index != undefined) {
      return state.instances[state.instanceSlugIndex[state.instanceBeingBuilt]];
    }
  },
  loaded(state: InstancesInterface) {
    return state.loaded
  },
  listAll(state: InstancesInterface) {
    return state.instances
  }
};

export default getters;
