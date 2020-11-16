import { GetterTree } from 'vuex';
import { StateInterface } from '../index';
import { LinksInterface } from './state';

const getters: GetterTree<LinksInterface, StateInterface> = {
    listAll(state: LinksInterface) {
      return state.links
    }
};

export default getters;
