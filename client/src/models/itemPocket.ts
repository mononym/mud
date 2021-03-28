export interface ItemPocketInterface {
  id: string;
  item_id: string;
  capacity: number;
  height: number;
  length: number;
  width: number;
}

const state: ItemPocketInterface = {
  id: "",
  item_id: "",
  capacity: 1,
  height: 1,
  length: 1,
  width: 1,
};

export default state;
