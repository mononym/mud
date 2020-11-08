export interface CommandSegmentInterface {
  id: string;
  match: string;
  key: string;
  greedy: boolean;
  dropWhitespace: boolean;
  transformer: string;
  type: string;
  multiple: string;
  follows: string[];
}

const SegmentState: CommandSegmentInterface = {
  id: '',
  match: '',
  key: '',
  greedy: true,
  dropWhitespace: true,
  transformer: 'none',
  type: 'text',
  multiple: 'none',
  follows: []
}

export {SegmentState}

export interface CommandInterface {
  id: string;
  name: string;
  description: string;
  instance_id: string;
  lua_script_id: string;
  segments: CommandSegmentInterface[]
}

const state: CommandInterface = {
  id: '',
  name: '',
  description: '',
  instance_id: '',
  lua_script_id: '',
  segments: []
};

export default state;