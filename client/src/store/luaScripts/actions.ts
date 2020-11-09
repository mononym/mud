import { ActionTree } from 'vuex';
import { StateInterface } from '../index';
import { LuaScriptInterface } from './state';
import axios, { AxiosResponse } from 'axios';

const actions: ActionTree<LuaScriptInterface, StateInterface> = {
  putScript({ commit }, script: LuaScriptInterface) {
    return new Promise(resolve => {
      commit('putScript', script);

      resolve();
    });
  },
  loadForInstance({ commit }, instanceId: string) {
    return new Promise((resolve, reject) => {
      axios
        .get('/lua_scripts/instance/' + instanceId)
        .then(function(response: AxiosResponse) {
          commit('putScripts', response.data);

          resolve();
        })
        .catch(function(e) {
          alert('Error when fetching scripts');
          alert(e);

          reject();
        });
    });
  },
  deleteScript({ commit }, scriptId: string) {
    return new Promise((resolve, reject) => {
      axios
        .delete('/lua_scripts/' + scriptId)
        .then(function() {
          commit('removeScript', scriptId);

          resolve();
        })
        .catch(function(e) {
          alert('Error when deleting script');
          alert(e);

          reject(e);
        });
    });
  }
};

export default actions;
