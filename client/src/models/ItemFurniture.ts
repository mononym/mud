export interface ItemFurnitureInterface {
  id: string;
  item_id: string;
  external_surface_can_hold_characters: boolean;
  external_surface_size: number;
  has_external_surface: boolean;
  internal_surface_can_hold_characters: boolean;
  internal_surface_size: number;
  has_internal_surface: boolean;
}

const state: ItemFurnitureInterface = {
  id: "",
  item_id: "",
  external_surface_can_hold_characters: false,
  external_surface_size: 1,
  has_external_surface: false,
  internal_surface_can_hold_characters: false,
  internal_surface_size: 1,
  has_internal_surface: false,
};

export default state;
