import { AreaInterface } from '../area/state';
import { MapInterface } from '../map/state';

import areaState from '../area/state';
import mapState from '../map/state';

export interface BuilderInterface {
  areaIndex: Record<string, number>;
  areas: AreaInterface[],
  areaUnderConstruction: AreaInterface,
  isAreaUnderConstruction: boolean,
  isAreaUnderConstructionNew: boolean,
  selectedArea: AreaInterface,
  isMapUnderConstruction: boolean,
  isMapUnderConstructionNew: boolean,
  mapIndex: Record<string, number>;
  maps: MapInterface[],
  mapUnderConstruction: MapInterface,
  selectedMap: MapInterface,
}

const state: BuilderInterface = {
  areaIndex: {},
  areas: [],
  areaUnderConstruction: {...areaState},
  isAreaUnderConstruction: false,
  isAreaUnderConstructionNew: true,
  selectedArea: {...areaState},
  isMapUnderConstruction: false,
  isMapUnderConstructionNew: true,
  mapIndex: {},
  maps: [],
  mapUnderConstruction: {...mapState},
  selectedMap: {...mapState},
};

export default state;
