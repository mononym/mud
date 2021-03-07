export interface ItemCoinInterface {
  id: string;
  item_id: string;
  copper: number;
  bronze: number;
  silver: number;
  gold: number;
}

const state: ItemCoinInterface = {
  id: "",
  item_id: "",
  copper: 0,
  bronze: 0,
  silver: 0,
  gold: 0,
};

export default state;
