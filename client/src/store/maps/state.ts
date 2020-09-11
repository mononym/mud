import { MapInterface } from '../map/state';

export interface MapsInterface {
  maps: Map<string, MapInterface>;
  fetched: boolean;
}

const state: MapsInterface = {
  fetched: false,
  maps: new Map(),
};

export default state;
