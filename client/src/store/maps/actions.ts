import { ActionTree } from 'vuex';
import { StateInterface } from '../index';
import { MapsInterface } from './state';
import { MapInterface } from '../map/state';
import axios, { AxiosResponse } from 'axios';

const actions: ActionTree<MapsInterface, StateInterface> = {
  fetchMap ({ commit, state }, mapId: string) {
    return new Promise((resolve, reject) => {
      if (state.maps.has(mapId)) {
        resolve(state.maps.get(mapId))
      } else {
        axios
          .get('/map/' + mapId)
          .then(function(response: AxiosResponse) {
            commit('putMap', response.data);

            resolve(response.data)
          })
          .catch(function() {
            commit('removeMapById', mapId);
  
            reject()
          });
      }
    })
  },
  putMap({ commit }, map: MapInterface) {
    commit('putMap', map);
  },
  removeMapById({ commit }, mapId: string) {
    commit('removeMap', mapId);
  }
};

export default actions;
