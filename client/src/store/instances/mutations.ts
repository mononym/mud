import { MutationTree } from 'vuex';
import { InstancesInterface } from './state';
import { InstanceInterface } from '../instance/state';
import Vue from 'vue';

const mutation: MutationTree<InstancesInterface> = {
  putInstanceBeingBuilt(state: InstancesInterface, instance: string) {
    Vue.set(state, 'instanceBeingBuilt', instance);
  },
  putInstance(state: InstancesInterface, instance: InstanceInterface) {
    Vue.set(state.instanceIndex, instance.id, state.instances.length);
    Vue.set(state.instanceSlugIndex, instance.slug, state.instances.length);

    state.instances.push(instance);
  },
  putInstances(state: InstancesInterface, instances: InstanceInterface[]) {
    state.instances = instances;
    state.instanceIndex = {};

    state.instances.forEach((instance, index) => {
      Vue.set(state.instanceIndex, instance.id, index);
      Vue.set(state.instanceSlugIndex, instance.slug, index);
    });
  },
  removeInstance(state: InstancesInterface, instanceId: string) {
    state.instances.splice(state.instanceIndex[instanceId], 1);
    state.instanceIndex = {};

    state.instances.forEach((instance, index) => {
      Vue.set(state.instanceIndex, instance.id, index);
    });
  }
};

export default mutation;
