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
  code: '',
  description: '',
  name: '',
  type: '',
  instance_id: '',
};

export {LuaScriptState}

export interface LuaScriptsInterface {
  scripts: Map<string, LuaScriptInterface>;
}

const state: LuaScriptsInterface = {
  scripts: new Map()
};


export default state;