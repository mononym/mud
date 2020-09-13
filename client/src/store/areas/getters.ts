import { GetterTree } from 'vuex';
import { StateInterface } from '../index';
import { AreasInterface } from './state';

const getters: GetterTree<AreasInterface, StateInterface> = {
  // getAreaById(state: AreasInterface, areaId: string) {
  //   state.areas.get(areaId);
  // }
};

export default getters;
