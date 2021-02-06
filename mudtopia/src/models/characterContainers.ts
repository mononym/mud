export interface CharacterContainersInterface {
  id: string;
  character_id: string;
  default_id: string;
  weapon_id: string;
  armor_id: string;
  gem_id: string;
  coin_id: string;
  ammunition_id: string;
  shield_id: string;
  clothing_id: string;
  scenery_id: string;
}

const state: CharacterContainersInterface = {
  id: "",
  character_id: "",
  default_id: "",
  weapon_id: "",
  armor_id: "",
  gem_id: "",
  coin_id: "",
  ammunition_id: "",
  shield_id: "",
  clothing_id: "",
  scenery_id: "",
};

export default state;
