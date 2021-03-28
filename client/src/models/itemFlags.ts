export interface ItemFlagsInterface {
  id: string;
  item_id: string;
  close: boolean;
  drop: boolean;
  hold: boolean;
  look: boolean;
  open: boolean;
  remove: boolean;
  stow: boolean;
  trash: boolean;
  wear: boolean;
  armor: boolean;
  clothing: boolean;
  coin: boolean;
  container: boolean;
  furniture: boolean;
  is_equipment: boolean;
  gem: boolean;
  gem_pouch: boolean;
  hidden: boolean;
  instrument: boolean;
  jewelry: boolean;
  material: boolean;
  scenery: boolean;
  shield: boolean;
  shop_display: boolean;
  weapon: boolean;
  wearable: boolean;
  has_surface: boolean;
  has_pocket: boolean;
}

const state: ItemFlagsInterface = {
  id: "",
  item_id: "",
  close: false,
  drop: false,
  hold: false,
  look: false,
  open: false,
  remove: false,
  stow: false,
  trash: false,
  wear: false,
  armor: false,
  clothing: false,
  coin: false,
  container: false,
  furniture: false,
  gem: false,
  gem_pouch: false,
  hidden: false,
  instrument: false,
  jewelry: false,
  material: false,
  scenery: false,
  shield: false,
  shop_display: false,
  weapon: false,
  wearable: false,
  is_equipment: false,
  has_surface: false,
  has_pocket: false,
};

export default state;
