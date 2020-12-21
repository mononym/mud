export interface CharacterRaceInterface {
  id: string;
  singular: string;
  plural: string;
  adjective: string;

  eyeColors: string[];
  eyeShapes: string[];
  eyeFeatures: string[];
  hairColors: string[];
  hairTypes: string[];
  hairStyles: string[];
  hairLengths: string[];
  heights: string[];
  skinTone: string[];
  portrait: string[];
  description: string[];
  pronouns: string[];
  ageMin: string[];
  ageMax: string[];
  bodyShapes: string[];
}

const state: CharacterRaceInterface = {
  id: "",
  singular: "",
  plural: "",
  adjective: "",

  eyeColors: [],
  eyeShapes: [],
  eyeFeatures: [],
  hairColors: [],
  hairTypes: [],
  hairStyles: [],
  hairLengths: [],
  heights: [],
  skinTone: [],
  portrait: [],
  description: [],
  pronouns: [],
  ageMin: [],
  ageMax: [],
  bodyShapes: [],
};

export default state;
