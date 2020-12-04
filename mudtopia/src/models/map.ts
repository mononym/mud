import type {MapLabelInterface} from './mapLabel'

export interface MapInterface {
  id: string;
  description: string;
  name: string;
  viewSize: number;
  gridSize: number;
  labels: MapLabelInterface[];
}

const state: MapInterface = {
  id: '',
  description: '',
  name: '',
  viewSize: 5000,
  gridSize: 10,
  labels: []
};

export default state;
