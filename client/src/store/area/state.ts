export interface AreaInterface {
  id: string;
  description: string;
  name: string;
  mapX: number;
  mapY: number;
  mapId: string;
  mapSize: number;
  instanceId: string;
  regionId: string;
}

const state: AreaInterface = {
  id: '',
  description: '',
  name: '',
  mapX: 0,
  mapY: 0,
  mapSize: 0,
  mapId: '',
  instanceId: '',
  regionId: '',
};

export default state;