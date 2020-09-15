export interface MapInterface {
  id: string;
  description: string;
  name: string;
  mapSize: number;
  gridSize: number;
  maxZoom: number;
  minZoom: number;
  defaultZoom: number;
}

const state: MapInterface = {
  id: '',
  description: '',
  name: '',
  mapSize: 1000,
  gridSize: 10,
  maxZoom: 500,
  minZoom: 1000,
  defaultZoom: 1000
};

export default state;
