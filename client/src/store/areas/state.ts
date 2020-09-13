import { AreaInterface } from '../area/state';

export interface AreasInterface {
  // allAreasIndex: string[];
  areasMap: Record<string, AreaInterface>;
  areasForMapIndex: Record<string, string[]>;
}

const state: AreasInterface = {
  // allAreasIndex: [],
  areasMap: {},
  areasForMapIndex: {}
};

export default state;
