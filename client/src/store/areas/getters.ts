import { GetterTree } from 'vuex';
import { StateInterface } from '../index';
import { AreasInterface } from './state';

const getters: GetterTree<AreasInterface, StateInterface> = {
  listAll(state: AreasInterface) {
    return state.areas
  }
};

export default getters;
