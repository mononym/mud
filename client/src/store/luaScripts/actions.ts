import { ActionTree } from 'vuex';
import { StateInterface } from '../index';
import { LuaScriptInterface } from './state';
import axios, { AxiosResponse } from 'axios';

const actions: ActionTree<LuaScriptInterface, StateInterface> = {
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
};

export default actions;
