import { GetterTree } from 'vuex';
import { StateInterface } from '../index';
import { LuaScriptsInterface } from './state';

const getters: GetterTree<LuaScriptsInterface, StateInterface> = {
  all(state: LuaScriptsInterface) {
    return Array.from(state.scripts.values())
  },
  allCommandScripts(state: LuaScriptsInterface) {
    return Array.from(state.scripts.values()).filter(script => script.type == 'Command')
  }
};

export default getters;
