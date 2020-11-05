import { MutationTree } from 'vuex';
import { LuaScriptInterface, LuaScriptsInterface } from './state';
import Vue from 'vue'

const mutation: MutationTree<LuaScriptsInterface> = {
    putScript(state: LuaScriptsInterface, script: LuaScriptInterface) {
      state.scripts.set(script.id, script);
    },
    putScripts(state: LuaScriptsInterface, scripts: LuaScriptInterface[]) {
      Vue.set(state, 'scripts',
       scripts.reduce(
        (map: Map<string, LuaScriptInterface>, script: LuaScriptInterface) => (
          (map.set(script.id, script)), map
        ),
        new Map()
      ))
    },
    removeScriptById(state: LuaScriptsInterface, scriptId: string) {
      state.scripts.delete(scriptId);
    }};

export default mutation;
