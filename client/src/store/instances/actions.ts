import { ActionTree } from 'vuex';
import { StateInterface } from '../index';
import { InstancesInterface } from './state';
import { InstanceInterface } from '../instance/state';
import axios, { AxiosResponse } from 'axios';

const actions: ActionTree<InstancesInterface, StateInterface> = {
  putInstances({ commit }, instances: InstanceInterface[]) {
    return new Promise(resolve => {
      commit('putInstances', instances);;

      resolve();
    });
  },
  ensureLoaded({ commit, state }, instance: string) {
    return new Promise((resolve, reject) => {
      if (state.instances[instance] == undefined) {
        axios
        .get('/instances/slug/' + instance)
        .then(function(response: AxiosResponse) {
          commit('putInstance', response.data);

          resolve();
        })
        .catch(function(e) {
          alert('Error when fetching instance: ' + instance);
          alert(e);

          reject();
        });
    }});
  },
  putInstance({ commit }, instance: InstanceInterface) {
    return new Promise(resolve => {
      commit('putInstance', instance);

      resolve();
    });
  },
  putInstanceBeingBuilt({ commit }, instance: InstanceInterface) {
    return new Promise(resolve => {
      commit('putInstanceBeingBuilt', instance);

      resolve();
    });
  },
  removeInstanceById({ commit }, instanceId: string) {
    return new Promise(resolve => {
      commit('removeInstance', instanceId);

      resolve();
    });
  }
};

export default actions;
