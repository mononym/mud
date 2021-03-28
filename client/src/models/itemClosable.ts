export interface ItemClosableInterface {
  id: string;
  item_id: string;
  open: boolean;
}

const state: ItemClosableInterface = {
  id: "",
  item_id: "",
  open: true,
};

export default state;
