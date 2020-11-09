import { MutationTree } from 'vuex';
import { LuaScriptInterface, LuaScriptsInterface } from './state';
import Vue from 'vue'

const mutation: MutationTree<LuaScriptsInterface> = {
    putScript(state: LuaScriptsInterface, script: LuaScriptInterface) {
      if (state.scriptIndex[script.id] != undefined) {
        Vue.set(state.scripts, state.scriptIndex[script.id], script)
      } else {
        Vue.set(state.scriptIndex, script.id, state.scripts.length);
    
        state.scripts.push(script);
      }
    },
    putScripts(state: LuaScriptsInterface, scripts: LuaScriptInterface[]) {
      state.scripts = scripts;
      state.scriptIndex = {};
  
      state.scripts.forEach((luaScript, index) => {
        Vue.set(state.scriptIndex, luaScript.id, index);
      });
    },
    removeScript(state: LuaScriptsInterface, scriptId: string) {
      state.scripts.splice(state.scriptIndex[scriptId], 1);
      state.scriptIndex = {};
  
      state.scripts.forEach((luaScript, index) => {
        Vue.set(state.scriptIndex, luaScript.id, index);
      });
    }};

export default mutation;
