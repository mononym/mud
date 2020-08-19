import { GetterTree } from 'vuex';
import { StateInterface } from '../index';
import { InstancesInterface } from './state';

const getters: GetterTree<InstancesInterface, StateInterface> = {
  getInstanceById(state: InstancesInterface, instanceId: string) {
    state.instances[instanceId];
  }
};

export default getters;
