export interface ItemDescriptionInterface {
  id: string;
  item_id: string;
  short: string;
  long: string;
}

const state: ItemDescriptionInterface = {
  id: "",
  item_id: "",
  short: "",
  long: "",
};

export default state;
