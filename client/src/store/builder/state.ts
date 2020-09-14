import { AreaInterface } from '../area/state';
import { MapInterface } from '../map/state';

import areaState from '../area/state';

export interface BuilderInterface {
  selectedAreaId: string;
  selectedMapId: string;
  mapIndex: Record<string, number>;
  areaIndex: Record<string, number>;
  maps: MapInterface[],
  areas: AreaInterface[],
  isAreaUnderConstruction: boolean,
  cloneSelectedArea: boolean,
  areaUnderConstruction: AreaInterface
}

const state: BuilderInterface = {
  selectedAreaId: '',
  selectedMapId: '',
  mapIndex: {},
  areaIndex: {},
  maps: [],
  areas: [],
  isAreaUnderConstruction: false,
  cloneSelectedArea: false,
  areaUnderConstruction: areaState
};

export default state;
