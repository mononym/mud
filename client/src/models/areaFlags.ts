export interface AreaFlagsInterface {
  id: string;
  area_id: string;
  bank: boolean;
  permanently_explored: boolean;
}

const state: AreaFlagsInterface = {
  id: "",
  area_id: "",
  bank: false,
  permanently_explored: false,
};

export default state;
