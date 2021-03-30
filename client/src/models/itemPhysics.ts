export interface ItemPhysicsInterface {
  id: string;
  item_id: string;
  weight: number;
  height: number;
  length: number;
  width: number;
}

const state: ItemPhysicsInterface = {
  id: "",
  item_id: "",
  weight: 0,
  height: 0,
  length: 0,
  width: 0,
};

export default state;
