import { ActionTree } from 'vuex';
import { StateInterface } from '../index';
import { RacesInterface } from './state';
import axios, { AxiosResponse } from 'axios';

const actions: ActionTree<RacesInterface, StateInterface> = {
    loadForInstance({ commit }, instanceId: string) {
      return new Promise((resolve, reject) => {
        axios
          .get('/character_races/instance/' + instanceId)
          .then(function(response: AxiosResponse) {
            commit('putRaces', response.data);
  
            resolve();
          })
          .catch(function(e) {
            alert('Error when fetching races');
            alert(e);
  
            reject();
          });
      });
    },};

export default actions;
