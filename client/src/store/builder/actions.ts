import { ActionTree } from 'vuex';
import { StateInterface } from '../index';
import { BuilderInterface } from './state';
import { AreaInterface } from '../area/state';
import { MapInterface } from '../map/state';
import { LinkInterface } from '../link/state';
import axios, { AxiosResponse } from 'axios';
import areaState from '../area/state';

const actions: ActionTree<BuilderInterface, StateInterface> = {
  fetchDataForMap({ commit, getters }, mapId: string) {
    return new Promise((resolve, reject) => {
      axios
        .get('/maps/' + mapId + '/data/')
        .then(function(response: AxiosResponse) {
          commit('putInternalAreas', response.data.internalAreas);
          commit('putExternalAreas', response.data.externalAreas);
          commit('putInternalLinks', response.data.internalLinks);
          commit('putExternalLinks', response.data.externalLinks);

          if (
            !getters['builder/isAreaSelected'] &&
            response.data.internalAreas.length > 0
          ) {
            commit('putSelectedArea', response.data.internalAreas[0]);
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
            void dispatch('fetchDataForMap', response.data[0].id);
          }

          resolve();
        })
        .catch(function() {
          alert('Error when fetching maps');

          reject();
        });
    });
  },
  updateMap({ commit }, map: MapInterface) {
    return new Promise(resolve => {
      commit('updateMap', map);

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
  putMap({ commit }, map: MapInterface) {
    return new Promise(resolve => {
      commit('putMap', map);

      resolve();
    });
  },
  putMapUnderConstruction({ commit }, map: MapInterface) {
    return new Promise(resolve => {
      commit('putMapUnderConstruction', map);

      resolve();
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
  resetAreas({ commit }) {
    return new Promise(resolve => {
      commit('putInternalAreas', []);
      commit('putSelectedArea', { ...areaState });

      resolve();
    });
  },
  putArea({ commit }, area: AreaInterface) {
    return new Promise(resolve => {
      commit('putArea', area);

      resolve();
    });
  },
  removeAreaById({ commit }, areaId: string) {
    commit('removeArea', areaId);
  },
  getArea({ state }, areaId: string) {
    if (Object.prototype.hasOwnProperty.call(state.internalAreaIndex, areaId)) {
      return state.internalAreas[state.internalAreaIndex[areaId]];
    } else {
      return state.externalAreas[state.externalAreaIndex[areaId]];
    }
  },
  deleteLink({ commit, state }) {
    return new Promise((resolve, reject) => {
      axios
        .delete('/links/' + state.selectedLink.id)
        .then(function() {
          commit('deleteLink', state.selectedLink.id);

          resolve();
        })
        .catch(function() {
          alert('Error when fetching maps');

          reject();
        });
    });
  },
  updateLink({ commit }, link: LinkInterface) {
    return new Promise(resolve => {
      commit('updateLink', link);
      commit('putSelectedLink', link);

      resolve();
    });
  },
  selectLink({ commit, state }, link: LinkInterface) {
    return new Promise(resolve => {
      if (state.selectedLink.id !== link.id) {
        commit('putSelectedLink', link);
      }

      resolve();
    });
  },
  putIsLinkUnderConstructionNew({ commit }, isIt: boolean) {
    return new Promise(resolve => {
      commit('putIsLinkUnderConstructionNew', isIt);

      resolve();
    });
  },
  putIsLinkUnderConstruction({ commit }, isIt: boolean) {
    return new Promise(resolve => {
      commit('putIsLinkUnderConstruction', isIt);

      resolve();
    });
  },
  putLinkUnderConstruction({ commit }, link: LinkInterface) {
    return new Promise(resolve => {
      commit('putLinkUnderConstruction', link);

      resolve();
    });
  },
  addLink({ commit }, link: LinkInterface) {
    return new Promise(resolve => {
      commit('addLink', link);

      resolve();
    });
  }
};

export default actions;
