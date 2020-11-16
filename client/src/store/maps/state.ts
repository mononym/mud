import { MapInterface } from '../map/state';

export interface MapsInterface {
  maps: MapInterface[];
  mapIndex: Record<string, number>;
}

const state: MapsInterface = {
  maps: [],
  mapIndex: {}
};

export default state;
