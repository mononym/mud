export interface ItemLocationInterface {
  id: string;
  hand: string;
  held_in_hand: boolean;
  item_id: string;
  area_id: string;
  character_id: string;
  relative_item_id: string;
  on_ground: boolean;
  relation: string;
  relative_to_item: boolean;
  worn_on_character: boolean;
  moved_at: string;
}

const state: ItemLocationInterface = {
  id: "",
  hand: "",
  held_in_hand: false,
  item_id: "",
  area_id: "",
  character_id: "",
  on_ground: false,
  relation: "",
  relative_to_item: false,
  relative_item_id: "",
  worn_on_character: false,
  moved_at: "",
};

export default state;
