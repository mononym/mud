import { GetterTree } from 'vuex';
import { StateInterface } from '../index';
import { CsrfInterface } from './state';

const getters: GetterTree<CsrfInterface, StateInterface> = {
  getCsrfToken(state) {
    return state.token;
  }
};

export default getters;
