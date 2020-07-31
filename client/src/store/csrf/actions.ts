import { ActionTree } from 'vuex';
import { StateInterface } from '../index';
import { CsrfInterface } from './state';
import axios, { AxiosResponse } from 'axios';

const actions: ActionTree<CsrfInterface, StateInterface> = {
  fetchCsrfToken(context) {
    return new Promise((resolve, reject) => {
      axios
        .post('/csrf-token')
        .then(function(response: AxiosResponse) {
          axios.defaults.headers.post['x-csrf-token'] = response.data;
          context.commit('setCsrfToken', response.data);
          resolve(response);
        })
        .catch(() => {
          reject(false);
        });
    });
  }
};

export default actions;
