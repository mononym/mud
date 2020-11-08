import { ActionTree } from 'vuex';
import { StateInterface } from '../index';
import { CommandsInterface } from './state';
import { CommandInterface } from '../command/state';
import axios, { AxiosResponse } from 'axios';

const actions: ActionTree<CommandsInterface, StateInterface> = {
  putCommand({ commit }, command: CommandInterface) {
    return new Promise(resolve => {
      commit('putCommand', command);

      resolve();
    });
  },
  putCommands({ commit }, commands: CommandInterface[]) {
    return new Promise(resolve => {
      commit('putCommands', commands);

      resolve();
    });
  },
  removeCommandById({ commit }, commandId: string) {
    return new Promise(resolve => {
      commit('removeCommand', commandId);

      resolve();
    });
  },
  deleteCommand({ commit }, commandId: string) {
    return new Promise((resolve, reject) => {
      axios
        .delete('/commands/' + commandId)
        .then(function() {
          commit('removeCommand', commandId);

          resolve();
        })
        .catch(function(e) {
          alert('Error when deleting command');
          alert(e);

          reject(e);
        });
    });
  }
};

export default actions;
