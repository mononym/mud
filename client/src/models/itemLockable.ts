export interface ItemLockableInterface {
  id: string;
  item_id: string;
  locked: boolean;
}

const state: ItemLockableInterface = {
  id: "",
  item_id: "",
  locked: false,
};

export default state;
