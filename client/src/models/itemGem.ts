export interface ItemGemInterface {
  id: string;
  item_id: string;
  type: string;
  cut_type: string;
  cut_quality: number;
  clarity: number;
  saturation: number;
  tone: number;
  hue: string;
  carat: number;
  pre_mod: string;
  post_mod: string;
}

const state: ItemGemInterface = {
  id: "",
  item_id: "",
  type: "",
  cut_type: "",
  cut_quality: 10,
  clarity: 5,
  saturation: 5,
  tone: 10,
  hue: "",
  carat: 10,
  pre_mod: "",
  post_mod: "",
};

export default state;
