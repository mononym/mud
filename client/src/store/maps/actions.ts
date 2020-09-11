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
          .get('/maps/' + mapId)
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
  fetchMaps ({ commit, state }) {
    return new Promise((resolve, reject) => {
      if (state.fetched) {
        resolve(state.maps.values())
      } else {
        axios
          .get('/maps')
          .then(function(response: AxiosResponse) {
            console.log('loaded maps')
            console.log(response.data)
            // console.log(response.data.reduce((map, obj) => (map.set(map.id, map), obj), new Map()))
            commit('setFetched', true);
            commit('putMaps', response.data.reduce((map, obj)=> (map.set(obj.id, obj)), new Map()));

            resolve(Array.from(state.maps.values()))
          })
          .catch(function() {
            alert('Error when fetching maps')
  
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
