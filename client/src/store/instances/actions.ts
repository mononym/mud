import { ActionTree } from 'vuex';
import { StateInterface } from '../index';
import { InstancesInterface } from './state';
import { InstanceInterface } from '../instance/state';

const actions: ActionTree<InstancesInterface, StateInterface> = {
  putInstances({ commit }, instances: InstanceInterface[]) {
    commit('putInstances', instances);
  },
  putInstance({ commit }, instance: InstanceInterface) {
    commit('putInstance', instance);
  },
  removeInstanceById({ commit }, instanceId: string) {
    commit('removeInstance', instanceId);
  }
};

export default actions;
