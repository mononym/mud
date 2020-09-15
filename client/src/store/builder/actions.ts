import { ActionTree } from 'vuex';
import { StateInterface } from '../index';
import { BuilderInterface } from './state';
import { AreaInterface } from '../area/state';
import { MapInterface } from '../map/state';
import axios, { AxiosResponse } from 'axios';
import areaState from '../area/state';

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
    commit('updateArea', area);
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
    commit('putArea', area);
  },
  removeAreaById({ commit }, areaId: string) {
    commit('removeArea', areaId);
  }
};

export default actions;
