import { ActionTree } from 'vuex';
import { StateInterface } from '../index';
import { PlayerInterface } from './state';
import axios, { AxiosResponse, AxiosError } from 'axios';

const actions: ActionTree<PlayerInterface, StateInterface> = {
  loadPlayer(context) {
    console.log('loading');
    axios
      .get('/player')
      .then(function(response: AxiosResponse) {
        console.log(response);
        void context.commit('setIsAuthenticated', true);
        void context.commit('setIsAuthenticating', false);
        void context.commit('setPlayerId', response.data.id);
        void context.dispatch('players/put', response.data);
        // void context.dispatch('settings/loadSettings');
      })
      .catch(function(error: AxiosError) {
        console.log(error);
        void context.commit('setPlayerId', null);
      });
  }
};

export default actions;
