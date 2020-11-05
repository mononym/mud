import { store } from 'quasar/wrappers';
import Vuex from 'vuex';

import auth from './auth';
import { AuthInterface } from './auth/state';

import player from './player';
import { PlayerInterface } from './player/state';

import players from './players';
import { PlayersInterface } from './players/state';

import instance from './instance';
import { InstanceInterface } from './instance/state';

import instances from './instances';
import { InstancesInterface } from './instances/state';

import map from './map';
import { MapInterface } from './map/state';

import maps from './maps';
import { MapsInterface } from './maps/state';

import area from './area';
import { AreaInterface } from './area/state';

import areas from './areas';
import { AreasInterface } from './areas/state';

import builder from './builder';
import { BuilderInterface } from './builder/state';

import character from './character';
import { CharacterInterface } from './character/state';

import characters from './characters';
import { CharactersInterface } from './characters/state';

import command from './command';
import { CommandInterface } from './command/state';

import commands from './commands';
import { CommandsInterface } from './commands/state';

import luaScripts from './luaScripts';
import { LuaScriptsInterface} from './luaScripts/state';

import races from './races';
import { RacesInterface } from './races/state';

/*
 * If not building with SSR mode, you can
 * directly export the Store instantiation
 */

export interface StateInterface {
  // Define your own store structure, using submodules if needed
  // example: ExampleStateInterface;
  // Declared as unknown to avoid linting issue. Best to strongly type as per the line above.
  auth: AuthInterface;
  player: PlayerInterface;
  players: PlayersInterface;
  instance: InstanceInterface;
  instances: InstancesInterface;
  map: MapInterface;
  maps: MapsInterface;
  area: AreaInterface;
  areas: AreasInterface;
  builder: BuilderInterface;
  character: CharacterInterface;
  characters: CharactersInterface;
  command: CommandInterface;
  commands: CommandsInterface;
  luaScripts: LuaScriptsInterface;
  races: RacesInterface
}

export default store(function({ Vue }) {
  Vue.use(Vuex);

  const Store = new Vuex.Store<StateInterface>({
    modules: {
      auth,
      player,
      players,
      instance,
      instances,
      map,
      maps,
      area,
      areas,
      builder,
      character,
      characters,
      command,
      commands,
      luaScripts,
      races
    },

    // enable strict mode (adds overhead!)
    // for dev mode only
    strict: !!process.env.DEV
  });

  return Store;
});
