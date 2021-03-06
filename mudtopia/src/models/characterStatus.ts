export interface CharacterStatusInterface {
  id: string;
  character_id: string;
  item_id: string;
  position: string;
  position_relation: string;
  position_relative_to_item: boolean;
}

const state: CharacterStatusInterface = {
  id: "",
  position: "",
  character_id: "",
  item_id: "",
  position_relation: "",
  position_relative_to_item: false,
};

export default state;
