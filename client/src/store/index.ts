import { store } from 'quasar/wrappers';
import Vuex from 'vuex';

import auth from './auth';
import { AuthInterface } from './auth/state';

import player from './player';
import { PlayerInterface } from './player/state';

import players from './players';
import { PlayersInterface } from './players/state';

import csrf from './csrf';
import { CsrfInterface } from './csrf/state';

import instance from './instance';
import { InstanceInterface } from './instance/state';

import instances from './instances';
import { InstancesInterface } from './instances/state';

/*
 * If not building with SSR mode, you can
 * directly export the Store instantiation
 */

export interface StateInterface {
  // Define your own store structure, using submodules if needed
  // example: ExampleStateInterface;
  // Declared as unknown to avoid linting issue. Best to strongly type as per the line above.
  auth: AuthInterface;
  csrf: CsrfInterface;
  player: PlayerInterface;
  players: PlayersInterface;
  instance: InstanceInterface;
  instances: InstancesInterface;
}

export default store(function({ Vue }) {
  Vue.use(Vuex);

  const Store = new Vuex.Store<StateInterface>({
    modules: {
      auth,
      csrf,
      player,
      players,
      instance,
      instances
    },

    // enable strict mode (adds overhead!)
    // for dev mode only
    strict: !!process.env.DEV
  });

  return Store;
});
