import { ActionTree } from 'vuex';
import { StateInterface } from '../index';
import { AreasInterface } from './state';
import { AreaInterface } from '../area/state';
import axios, { AxiosResponse } from 'axios';

const actions: ActionTree<AreasInterface, StateInterface> = {
  loadForMap({ commit }, mapId: string) {
    return new Promise((resolve, reject) => {
      axios
        .get('/areas/map/' + mapId)
        .then(function(response: AxiosResponse) {
          commit('putAreas', response.data);

          resolve();
        })
        .catch(function(e) {
          alert('Error when fetching areas');
          alert(e);

          reject();
        });
    });
  },
  putArea({ commit }, area: AreaInterface) {
    commit('putArea', area);
  },
  deleteArea({ commit }, areaId: string) {
    return new Promise((resolve, reject) => {
      axios
        .delete('/areas/' + areaId)
        .then(function() {
          commit('removeArea', areaId);

          resolve();
        })
        .catch(function(e) {
          alert('Error when deleting area');
          alert(e);

          reject();
        });
    });
  }
};

export default actions;
