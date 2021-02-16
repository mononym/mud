export interface CharacterBankInterface {
  id: string;
  character_id: string;
  balance: number;
}

const state: CharacterBankInterface = {
  id: "",
  balance: 0,
  character_id: "",
};

export default state;
