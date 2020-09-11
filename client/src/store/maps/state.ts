import { MapInterface } from '../map/state';

export interface MapsInterface {
  maps: Map<string, MapInterface>;
}

const state: MapsInterface = {
  maps: new Map()
};

export default state;
