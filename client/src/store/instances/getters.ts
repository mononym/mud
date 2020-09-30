import { GetterTree } from 'vuex';
import { StateInterface } from '../index';
import { InstancesInterface } from './state';

const getters: GetterTree<InstancesInterface, StateInterface> = {
  // getInstanceBySlug(state: InstancesInterface, slug: string) {
  //   state.instances[slug];
  // },
  getInstanceBySlug: (state: InstancesInterface) => (slug: string) => {
    return state.instances[slug];
  }
};

export default getters;
