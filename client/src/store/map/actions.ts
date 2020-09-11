import { ActionTree } from 'vuex';
import { StateInterface } from '../index';
import { MapInterface } from './state';
import axios, { AxiosResponse, AxiosError } from 'axios';

const actions: ActionTree<MapInterface, StateInterface> = {
  loadMap(context) {
    console.log('loading');
    axios
      .get('/map')
      .then(function(response: AxiosResponse) {
        console.log(response);
        void context.commit('setIsAuthenticated', true);
        void context.commit('setIsAuthenticating', false);
        void context.commit('setMapId', response.data.id);
        void context.dispatch('maps/put', response.data);
        // void context.dispatch('settings/loadSettings');
      })
      .catch(function(error: AxiosError) {
        console.log(error);
        void context.commit('setMapId', null);
      });
  }
};

export default actions;
