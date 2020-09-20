import { AreaInterface } from '../area/state';

export interface AreasInterface {
  // areasIndex: string[];
  areasMap: Record<string, AreaInterface>;
  areasForMapIndex: Record<string, string[]>;
}

const state: AreasInterface = {
  // areasIndex: [],
  areasMap: {},
  areasForMapIndex: {}
};

export default state;
