export interface ItemDescriptionInterface {
  id: string;
  item_id: string;
  short: string;
  long: string;
  key: string;
}

const state: ItemDescriptionInterface = {
  id: "",
  item_id: "",
  short: "",
  long: "",
  key: "",
};

export default state;
