import { ActionTree } from 'vuex';
import { StateInterface } from '../index';
import { BuilderInterface } from './state';
import { AreaInterface } from '../area/state';
import { MapInterface } from '../map/state';
import axios, { AxiosResponse } from 'axios';
import areaState from '../area/state';

const actions: ActionTree<BuilderInterface, StateInterface> = {
  fetchAreasForMap({ commit, getters }, mapId: string) {
    return new Promise((resolve, reject) => {
      axios
        .get('/areas/map/' + mapId)
        .then(function(response: AxiosResponse) {
          commit('putAreas', response.data);

          if (!getters['builder/isAreaSelected'] && response.data.length > 0) {
            commit('putSelectedArea', response.data[0]);
          }

          resolve();
        })
        .catch(function(e) {
          alert('Error when fetching areas');
          alert(e);

          reject();
        });
    });
  },
  fetchMaps({ commit, dispatch }) {
    return new Promise((resolve, reject) => {
      axios
        .get('/maps')
        .then(function(response: AxiosResponse) {
          commit('putMaps', response.data);

          if (response.data.length > 0) {
            commit('putSelectedMap', response.data[0]);
            void dispatch('fetchAreasForMap', response.data[0].id);
          }

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
        .delete('/areas/' + state.selectedArea.id)
        .then(function() {
          commit('deleteArea', state.selectedArea.id);

          resolve();
        })
        .catch(function() {
          alert('Error when fetching maps');

          reject();
        });
    });
  },
  updateArea({ commit }, area: AreaInterface) {
    return new Promise(resolve => {
      commit('updateArea', area);
      commit('putSelectedArea', area);

      resolve();
    });
  },
  updateMap({ commit }, map: MapInterface) {
    return new Promise(resolve => {
      commit('updateMap', map);

      resolve();
    });
  },
  selectArea({ commit, state }, area: AreaInterface) {
    return new Promise(resolve => {
      if (state.selectedArea.id !== area.id) {
        commit('putSelectedArea', area);
      }

      resolve();
    });
  },
  putIsAreaUnderConstructionNew({ commit }, isIt: boolean) {
    return new Promise(resolve => {
      commit('putIsAreaUnderConstructionNew', isIt);

      resolve();
    });
  },
  putIsMapUnderConstructionNew({ commit }, isIt: boolean) {
    return new Promise(resolve => {
      commit('putIsMapUnderConstructionNew', isIt);

      resolve();
    });
  },
  putIsMapUnderConstruction({ commit }, isIt: boolean) {
    return new Promise(resolve => {
      commit('putIsMapUnderConstruction', isIt);

      resolve();
    });
  },
  putIsAreaUnderConstruction({ commit }, isIt: boolean) {
    return new Promise(resolve => {
      commit('putIsAreaUnderConstruction', isIt);

      resolve();
    });
  },
  putAreaUnderConstruction({ commit }, area: AreaInterface) {
    return new Promise(resolve => {
      commit('putAreaUnderConstruction', area);

      resolve();
    });
  },
  putMapUnderConstruction({ commit }, map: MapInterface) {
    return new Promise(resolve => {
      commit('putMapUnderConstruction', map);

      resolve();
    });
  },
  resetAreas({ commit }) {
    return new Promise(resolve => {
      commit('putAreas', []);
      commit('putSelectedArea', { ...areaState });

      resolve();
    });
  },
  selectMap({ commit, state }, map: MapInterface) {
    return new Promise(resolve => {
      if (state.selectedMap.id !== map.id) {
        commit('putSelectedMap', map);
      }

      resolve();
    });
  },
  addMap({ commit }, map: string) {
    return new Promise(resolve => {
      commit('addMap', map);

      resolve();
    });
  },
  putArea({ commit }, area: AreaInterface) {
    return new Promise(resolve => {
      commit('putArea', area);

      resolve();
    });
  },
  putMap({ commit }, map: MapInterface) {
    return new Promise(resolve => {
      commit('putMap', map);

      resolve();
    });
  },
  removeAreaById({ commit }, areaId: string) {
    commit('removeArea', areaId);
  }
};

export default actions;
