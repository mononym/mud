export interface ItemPocketInterface {
  id: string;
  item_id: string;
  capacity: number;
  height: number;
  item_limit: number;
  length: number;
  width: number;
}

const state: ItemPocketInterface = {
  id: "",
  item_id: "",
  capacity: 0,
  height: 0,
  item_limit: 0,
  length: 0,
  width: 0,
};

export default state;
