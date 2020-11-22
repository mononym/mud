import { ActionTree } from 'vuex';
import { StateInterface } from '../index';
import { LinksInterface } from './state';
import { LinkInterface } from '../link/state';
import axios, { AxiosResponse } from 'axios';

const actions: ActionTree<LinksInterface, StateInterface> = {
  loadForMap({ commit }, mapId: string) {
    return new Promise((resolve, reject) => {
      axios
        .get('/links/map/' + mapId)
        .then(function(response: AxiosResponse) {
          commit('putLinks', response.data);

          resolve();
        })
        .catch(function(e) {
          alert('Error when fetching links');
          alert(e);

          reject();
        });
    });
  },
  putLinks({ commit }, links: LinkInterface[]) {
    commit('putLinks', links);
  },
  putLink({ commit }, link: LinkInterface) {
    commit('putLink', link);
  },
  removeLinkById({ commit }, linkId: string) {
    commit('removeLink', linkId);
  },
  clear({ commit }) {
    return new Promise((resolve) => {
      commit('clear');

      resolve();
    });
  },
  deleteLink({ commit }, linkId: string) {
    return new Promise((resolve, reject) => {
      axios
        .delete('/links/' + linkId)
        .then(function() {
          commit('removeLink', linkId);

          resolve();
        })
        .catch(function(e) {
          alert('Error when deleting link');
          alert(e);

          reject();
        });
    });
  }
};

export default actions;
