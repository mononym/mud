import { CommandInterface } from '../command/state';

export interface CommandsInterface {
  commands: Map<string, CommandInterface>;
}

const state: CommandsInterface = {
  commands: new Map(),
};

export default state;
