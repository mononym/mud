import { ActionTree } from 'vuex';
import { StateInterface } from '../index';
import { AreasInterface } from './state';
import { AreaInterface } from '../area/state';
import axios, { AxiosResponse } from 'axios';

const actions: ActionTree<AreasInterface, StateInterface> = {
  fetchArea({ commit, state }, areaId: string) {
    return new Promise((resolve, reject) => {
      if (Object.prototype.hasOwnProperty.call(state.areasMap, areaId)) {
        resolve({ ...state.areasMap[areaId] });
      } else {
        axios
          .get('/areas/' + areaId)
          .then(function(response: AxiosResponse) {
            commit('putArea', response.data);

            resolve(response.data);
          })
          .catch(function() {
            commit('removeArea', areaId);

            reject();
          });
      }
    });
  },
  putArea({ commit }, area: AreaInterface) {
    commit('putArea', area);
  },
  removeAreaById({ commit }, areaId: string) {
    commit('removeArea', areaId);
  }
};

export default actions;
