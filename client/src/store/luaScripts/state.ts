export interface LuaScriptInterface {
  id: string;
  code: string;
  description: string;
  name: string;
  type: string;
  instance_id: string;
}

const LuaScriptState: LuaScriptInterface = {
  id: '',
  code: 'print("Hello World!")',
  description: '',
  name: '',
  type: '',
  instance_id: '',
};

export {LuaScriptState}

export interface LuaScriptsInterface {
  scripts: LuaScriptInterface[];
  scriptIndex: Record<string, number>;
}

const state: LuaScriptsInterface = {
  scripts: [],
  scriptIndex: {}
};


export default state;