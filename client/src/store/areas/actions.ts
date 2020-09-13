import { ActionTree } from 'vuex';
import { StateInterface } from '../index';
import { AreasInterface } from './state';
import { AreaInterface } from '../area/state';
import axios, { AxiosResponse } from 'axios';

const actions: ActionTree<AreasInterface, StateInterface> = {
  fetchArea({ commit, state }, areaId: string) {
    return new Promise((resolve, reject) => {
      if (state.areasMap.hasOwnProperty(areaId)) {
        resolve({...state.areasMap[areaId]});
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
  fetchAreasForMap({ commit, state }, mapId: string) {
    return new Promise((resolve, reject) => {
      axios
        .get('/areas/map/' + mapId)
        .then(function(response: AxiosResponse) {
          console.log('loaded areas');
          console.log(response.data);
          const areas = {}
          response.data.forEach(element => {
            areas[element.id] = element
          });

          console.log(areas)

          commit('putAreasForMap', { areas, mapId });
          
          resolve(response.data);
        })
        .catch(function() {
          alert('Error when fetching areas');

          reject();
        });
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
