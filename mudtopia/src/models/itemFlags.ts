export interface ItemFlagsInterface {
  id: string;
  item_id: string;
  close: boolean;
  drop: boolean;
  gem: boolean;
  gem_pouch: boolean;
  hidden: boolean;
  hold: boolean;
  look: boolean;
  open: boolean;
  remove: boolean;
  store: boolean;
  trash: boolean;
  wear: boolean;
  armor: boolean;
  clothing: boolean;
  container: boolean;
  furniture: boolean;
  instrument: boolean;
  jewellery: boolean;
  material: boolean;
  shield: boolean;
  weapon: boolean;
  scenery: boolean;
  wearable: boolean;
}

const state: ItemFlagsInterface = {
  id: "",
  item_id: "",
  close: false,
  drop: false,
  hidden: false,
  gem: false,
  gem_pouch: false,
  hold: false,
  look: false,
  open: false,
  remove: false,
  store: false,
  trash: false,
  wear: false,
  armor: false,
  clothing: false,
  container: false,
  furniture: false,
  instrument: false,
  jewellery: false,
  material: false,
  shield: false,
  weapon: false,
  scenery: false,
  wearable: false,
};

export default state;
