import { ActionTree } from 'vuex';
import { StateInterface } from '../index';
import { MapsInterface } from './state';
import { MapInterface } from '../map/state';
import axios, { AxiosResponse } from 'axios';

const actions: ActionTree<MapsInterface, StateInterface> = {
  loadForInstance({ commit }, mapId: string) {
    return new Promise((resolve, reject) => {
      axios
        .get('/maps/instance/' + mapId)
        .then(function(response: AxiosResponse) {
          commit('putMaps', response.data);

          resolve();
        })
        .catch(function(e) {
          alert('Error when fetching maps');
          alert(e);

          reject();
        });
    });
  },
  putMap({ commit }, map: MapInterface) {
    commit('putMap', map);
  },
  deleteMap({ commit }, mapId: string) {
    return new Promise((resolve, reject) => {
      axios
        .delete('/maps/' + mapId)
        .then(function() {
          commit('removeMap', mapId);

          resolve();
        })
        .catch(function(e) {
          alert('Error when deleting map');
          alert(e);

          reject();
        });
    });
  }
};

export default actions;
