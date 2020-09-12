import { MapInterface } from '../map/state';

export interface MapsInterface {
  mapsList: MapInterface[];
  mapsMap: Map<string, MapInterface>;
  fetched: boolean;
}

const state: MapsInterface = {
  fetched: false,
  mapsList: [],
  mapsMap: new Map(),
};

export default state;
