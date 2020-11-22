import { ActionTree } from 'vuex';
import { StateInterface } from '../index';
import { MapsInterface } from './state';
import { MapInterface } from '../map/state';
import axios, { AxiosResponse } from 'axios';

const actions: ActionTree<MapsInterface, StateInterface> = {
  loadForInstance({ commit }, instanceId: string) {
    return new Promise((resolve, reject) => {
      axios
        .get('/maps/instance/' + instanceId)
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
  loadDataForMap({ dispatch }, mapId: string) {
    return new Promise((resolve, reject) => {
      axios
        .get('/maps/' + mapId + '/data')
        .then(function(response: AxiosResponse) {
          void dispatch('areas/putAreas', response.data.areas, {root:true})
          void dispatch('links/putLinks', response.data.links, {root:true})

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
