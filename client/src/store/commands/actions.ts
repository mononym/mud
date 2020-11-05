import { ActionTree } from 'vuex';
import { StateInterface } from '../index';
import { CommandsInterface } from './state';
import { CommandInterface } from '../command/state';

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
  }
};

export default actions;
