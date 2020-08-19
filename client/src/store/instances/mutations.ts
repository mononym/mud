import { MutationTree } from 'vuex';
import { InstancesInterface } from './state';
import { InstanceInterface } from '../instance/state';
import Vue from 'vue';

const mutation: MutationTree<InstancesInterface> = {
  putInstance(state: InstancesInterface, instance: InstanceInterface) {
    Vue.set(state.instances, instance.id, instance)
  },
  removeInstanceById(state: InstancesInterface, instanceId: string) {
    Vue.delete(state.instances, instanceId)
  }
};

export default mutation;
