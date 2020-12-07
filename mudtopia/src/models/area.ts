export interface AreaInterface {
  id: string;
  description: string;
  name: string;
  mapX: number;
  mapY: number;
  mapId: string;
  mapSize: number;
  mapCorners: number;
}

const state: AreaInterface = {
  id: "",
  description: "",
  name: "",
  mapX: 0,
  mapY: 0,
  mapSize: 21,
  mapCorners: 5,
  mapId: "",
};

export default state;
