export interface CharacterWealthInterface {
  id: string;
  character_id: string;
  copper: number;
  bronze: number;
  silver: number;
  gold: number;
}

const state: CharacterWealthInterface = {
  id: "",
  character_id: "",
  copper: 0,
  bronze: 0,
  silver: 0,
  gold: 0,
};

export default state;
