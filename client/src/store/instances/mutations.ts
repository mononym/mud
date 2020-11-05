import { MutationTree } from 'vuex';
import { InstancesInterface } from './state';
import { InstanceInterface } from '../instance/state';
import Vue from 'vue';

const mutation: MutationTree<InstancesInterface> = {
  putInstance(state: InstancesInterface, instance: InstanceInterface) {
    Vue.set(state.instances, instance.slug, instance);
  },
  putInstanceBeingBuilt(state: InstancesInterface, instance: string) {
    state.instanceBeingBuilt = instance
  },
  removeInstanceById(state: InstancesInterface, instanceId: string) {
    Vue.delete(state.instances, instanceId);
  },
  putInstances(state: InstancesInterface, instances: InstancesInterface[]) {
    const initialValue = {};
    state.instances = instances.reduce((obj, item) => {
      return {
        ...obj,
        [item.slug]: item
      };
    }, initialValue);
  }
};

export default mutation;
