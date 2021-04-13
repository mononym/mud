export interface ItemDescriptionInterface {
  id: string;
  item_id: string;
  short: string;
  details: string;
  key: string;
}

const state: ItemDescriptionInterface = {
  id: "",
  item_id: "",
  short: "",
  details: "There is nothing unusual to see.",
  key: "",
};

export default state;
