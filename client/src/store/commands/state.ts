import { CommandInterface } from '../command/state';

export interface CommandsInterface {
  commands: CommandInterface[];
  commandIndex: Record<string, number>;
}

const state: CommandsInterface = {
  commands: [],
  commandIndex: {}
};

export default state;
