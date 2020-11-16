import { AreaInterface } from '../area/state';

export interface AreasInterface {
  areas: AreaInterface[];
  areaIndex: Record<string, number>;
}

const state: AreasInterface = {
  areas: [],
  areaIndex: {}
};

export default state;
