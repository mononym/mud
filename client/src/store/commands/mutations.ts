import { MutationTree } from 'vuex';
import { CommandsInterface } from './state';
import { CommandInterface } from '../command/state';
import Vue from 'vue'

const mutation: MutationTree<CommandsInterface> = {
  putCommand(state: CommandsInterface, command: CommandInterface) {
    Vue.set(state.commandIndex, command.id, state.commands.length);

    state.commands.push(command);
  },
  putCommands(state: CommandsInterface, commands: CommandInterface[]) {
    state.commands = commands;
    state.commandIndex = {};

    state.commands.forEach((command, index) => {
      Vue.set(state.commandIndex, command.id, index);
    });
  },
  removeCommand(state: CommandsInterface, commandId: string) {
    state.commands.splice(state.commandIndex[commandId], 1);
    state.commandIndex = {};

    state.commands.forEach((command, index) => {
      Vue.set(state.commandIndex, command.id, index);
    });
  }
};

export default mutation;
