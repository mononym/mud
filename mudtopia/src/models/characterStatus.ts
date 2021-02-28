export interface CharacterStatusInterface {
  id: string;
  character_id: string;
  position: string;
}

const state: CharacterStatusInterface = {
  id: "",
  position: "",
  character_id: "",
};

export default state;
