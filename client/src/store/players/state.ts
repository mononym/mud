import { PlayerInterface } from '../player/state';

export interface PlayersInterface {
  players: Map<string, PlayerInterface>;
}

const state: PlayersInterface = {
  players: new Map()
};

export default state;
