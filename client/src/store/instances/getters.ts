import { GetterTree } from 'vuex';
import { StateInterface } from '../index';
import { InstancesInterface } from './state';

const getters: GetterTree<InstancesInterface, StateInterface> = {
  instanceBeingBuilt(state: InstancesInterface) {
    return state.instances[state.instanceBeingBuilt];
  }
};

export default getters;
