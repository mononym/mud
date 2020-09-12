import { ActionTree } from 'vuex';
import { StateInterface } from '../index';
import { MapsInterface } from './state';
import { MapInterface } from '../map/state';
import axios, { AxiosResponse } from 'axios';

const actions: ActionTree<MapsInterface, StateInterface> = {
  fetchMap ({ commit, state }, mapId: string) {
    return new Promise((resolve, reject) => {
      if (state.mapsMap.has(mapId)) {
        console.log('map is local')
        console.log(state.mapsMap.has(mapId))
        resolve(state.mapsMap.get(mapId))
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
        resolve(state.mapsList)
      } else {
        axios
          .get('/maps')
          .then(function(response: AxiosResponse) {
            console.log('loaded maps')
            console.log(response.data)
            // console.log(response.data.reduce((map, obj) => (map.set(map.id, map), obj), new Map()))
            commit('setFetched', true);
            commit('putMaps', response.data.reduce((map, obj)=> (map.set(obj.id, obj)), new Map()));

            resolve(state.mapsList)
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
