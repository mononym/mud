export interface AreaInterface {
  id: string;
  description: string;
  name: string;
  mapX: number;
  mapY: number;
  mapId: string;
  mapSize: number;
}

const state: AreaInterface = {
  id: '',
  description: '',
  name: '',
  mapX: 0,
  mapY: 0,
  mapSize: 20,
  mapId: '',
};

export default state;