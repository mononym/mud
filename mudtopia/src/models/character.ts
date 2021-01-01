import CharacterSettingsState, {
  CharacterSettingsInterface,
} from "./characterSettings";

export interface CharacterInterface {
  id: string;
  slug: string;
  name: string;
  active: boolean;
  handedness: string;
  genderPronoun: string;

  strength: number;
  stamina: number;
  constitution: number;
  dexterity: number;
  agility: number;
  reflexes: number;
  intelligence: number;
  wisdom: number;
  charisma: number;

  age: number;
  race: string;
  eyeColor: string;
  eyeAccentColor: string;
  eyeColorType: string;
  hairColor: string;
  hairLength: string;
  hairStyle: string;
  skinTone: string;
  position: string;
  height: string;
  player_id: string;
  area_id: string;

  settings: CharacterSettingsInterface;
}

const state: CharacterInterface = {
  id: "",
  slug: "",
  name: "",
  active: false,
  handedness: "right",
  genderPronoun: "neutral",

  strength: 10,
  stamina: 10,
  constitution: 10,
  dexterity: 10,
  agility: 10,
  reflexes: 10,
  intelligence: 10,
  wisdom: 10,
  charisma: 10,

  age: 20,
  race: "",
  eyeColor: "",
  eyeAccentColor: "",
  eyeColorType: "",
  hairColor: "",
  hairLength: "",
  hairStyle: "",
  skinTone: "",
  position: "",
  height: "",
  player_id: "",
  area_id: "",

  settings: { ...CharacterSettingsState },
};

export default state;
