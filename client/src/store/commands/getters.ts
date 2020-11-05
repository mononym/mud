import { GetterTree } from 'vuex';
import { StateInterface } from '../index';
import { CommandsInterface } from './state';

const getters: GetterTree<CommandsInterface, StateInterface> = {
  getCommandById(state: CommandsInterface, commandId: string) {
    return state.commands.get(commandId);
  },
  all(state: CommandsInterface) {
    return Array.from(state.commands.values())
  }
};

export default getters;
