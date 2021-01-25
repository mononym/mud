export interface ItemPhysicsInterface {
  id: string;
  weight: number;
  height: number;
  length: number;
  width: number;
}

const state: ItemPhysicsInterface = {
  id: "",
  weight: 1,
  height: 1,
  length: 1,
  width: 1,
};

export default state;
