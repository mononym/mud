import { MutationTree } from 'vuex';
import { CommandsInterface } from './state';
import { CommandInterface } from '../command/state';

const mutation: MutationTree<CommandsInterface> = {
  putCommand(state: CommandsInterface, command: CommandInterface) {
    state.commands.set(command.id, command);
  },
  putCommands(state: CommandsInterface, commands: CommandInterface[]) {
    state.commands = commands.reduce(
      (map: Map<string, CommandInterface>, command: CommandInterface) => (
        (map.set(command.id, command)), map
      ),
      new Map()
    );
  },
  removeCommandById(state: CommandsInterface, commandId: string) {
    state.commands.delete(commandId);
  }
};

export default mutation;
