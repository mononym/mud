import { ActionTree } from 'vuex';
import { StateInterface } from '../index';
import { BuilderInterface } from './state';
import { AreaInterface } from '../area/state';
import axios, { AxiosResponse } from 'axios';

const actions: ActionTree<BuilderInterface, StateInterface> = {
  fetchAreasForMap({ commit }, mapId: string) {
    return new Promise((resolve, reject) => {
      axios
        .get('/areas/map/' + mapId)
        .then(function(response: AxiosResponse) {
          commit('putAreas', response.data);

          resolve();
        })
        .catch(function() {
          alert('Error when fetching areas');

          reject();
        });
    });
  },
  fetchMaps({ commit }) {
    return new Promise((resolve, reject) => {
      axios
        .get('/maps')
        .then(function(response: AxiosResponse) {
          commit('putMaps', response.data);

          resolve();
        })
        .catch(function() {
          alert('Error when fetching maps');

          reject();
        });
    });
  },
  deleteArea({ commit, state }) {
    return new Promise((resolve, reject) => {
      axios
        .delete('/areas/' + state.selectedAreaId)
        .then(function() {
          commit('deleteArea', state.selectedAreaId);

          resolve();
        })
        .catch(function() {
          alert('Error when fetching maps');

          reject();
        });
    });
  },
  updateArea({ commit }, area: AreaInterface) {
    commit('updateArea', area);
  },
  selectArea({ commit }, areaId: string) {
    return new Promise((resolve) => {
      commit('putSelectedArea', areaId);

      resolve()
    });
  },
  clearAreas({ commit }) {
    commit('putAreas', []);
  },
  selectMap({ commit }, mapId: string) {
    commit('putSelectedMapId', mapId);
  },
  putArea({ commit }, area: AreaInterface) {
    commit('putArea', area);
  },
  removeAreaById({ commit }, areaId: string) {
    commit('removeArea', areaId);
  },
  putIsAreaUnderConstruction({ commit }, isIt: boolean) {
    commit('putIsAreaUnderConstruction', isIt);
  },
  putCloneSelectedArea({ commit }, clone: boolean) {
    commit('putCloneSelectedArea', clone);
  },
  putAreaUnderConstruction({ commit }, area: AreaInterface) {
    commit('putAreaUnderConstruction', area);
  }
};

export default actions;
