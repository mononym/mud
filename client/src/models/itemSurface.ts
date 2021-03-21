export interface ItemSurfaceInterface {
  id: string;
  item_id: string;
  can_hold_characters: boolean;
  item_weight_limit: number;
  item_count_limit: number;
  character_limit: number;
  show_item_contents: boolean;
  show_detailed_items: boolean;
  show_item_limit: number;
}

const state: ItemSurfaceInterface = {
  id: "",
  item_id: "",
  can_hold_characters: false,
  item_weight_limit: 1,
  item_count_limit: 1,
  character_limit: 1,
  show_item_contents: false,
  show_detailed_items: false,
  show_item_limit: 1,
};

export default state;
