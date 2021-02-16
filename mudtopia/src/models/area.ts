import AreaFlagsState, { AreaFlagsInterface } from "./areaFlags";

export interface AreaInterface {
  id: string;
  description: string;
  name: string;
  mapX: number;
  mapY: number;
  mapId: string;
  mapSize: number;
  mapCorners: number;
  color: string;
  borderWidth: number;
  borderColor: string;
  flags: AreaFlagsInterface;
}

const state: AreaInterface = {
  id: "",
  description: "",
  name: "",
  mapX: 0,
  mapY: 0,
  mapSize: 20,
  mapCorners: 5,
  mapId: "",
  color: "#696969",
  borderColor: "#FFFFFF",
  borderWidth: 2,
  flags: { ...AreaFlagsState },
};

export default state;
