import { MutationTree } from 'vuex';
import { LinksInterface } from './state';
import { LinkInterface } from '../link/state';
import Vue from 'vue'

const mutation: MutationTree<LinksInterface> = {
    putLink(state: LinksInterface, link: LinkInterface) {
      Vue.set(state.linkIndex, link.id, state.links.length);
  
      state.links.push(link);
    },
    putLinks(state: LinksInterface, links: LinkInterface[]) {
      state.links = links;
      state.linkIndex = {};
  
      state.links.forEach((link, index) => {
        Vue.set(state.linkIndex, link.id, index);
      });
    },
    clear(state: LinksInterface) {
      state.links = [];
      state.linkIndex = {};
    },
    removeLink(state: LinksInterface, linkId: string) {
      state.links.splice(state.linkIndex[linkId], 1);
      state.linkIndex = {};
  
      state.links.forEach((link, index) => {
        Vue.set(state.linkIndex, link.id, index);
      });
    }
};

export default mutation;
