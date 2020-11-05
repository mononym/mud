export interface CommandPartInterface {
  id: string;
  matches: string;
  key: string;
  follows: string[];
  greedy: boolean;
  drop_whitespace: boolean;
  transformer: string;
}

const PartState: CommandPartInterface = {
  id: '',
  matches: '',
  follows: [],
  key: '',
  greedy: true,
  drop_whitespace: true,
  transformer: '',
}

export {PartState}

export interface CommandInterface {
  id: string;
  name: string;
  description: string;
  instance_id: string;
  lua_script_id: string;
  parts: CommandPartInterface[]
}

const state: CommandInterface = {
  id: '',
  name: '',
  description: '',
  instance_id: '',
  lua_script_id: '',
  parts: []
};

export default state;