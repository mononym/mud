interface HairStyleInterface {
  lengths: string[];
  style: string;
}

export interface RaceInterface {
  id: string;
  eyeColors: string[];
  eyeShapes: string[];
  eyeFeatures: string[];
  hairColors: string[];
  hairTypes: string[];
  hairStyles: HairStyleInterface[];
  hairLengths: string[];
  heights: string[];
  skinColors: string[];
  portrait: string;
  description: string;
  pronouns: string[];
  ageMin: number;
  ageMax: number;
  bodyShapes: string[];
  singular: string;
  plural: string;
}

const state: RaceInterface = {
  id: '',
  eyeColors: [],
  eyeShapes: [],
  eyeFeatures: [],
  hairColors: [],
  hairTypes: [],
  hairStyles: [],
  hairLengths: [],
  heights: [],
  skinColors: [],
  portrait: '',
  description: '',
  pronouns: [],
  ageMin: 0,
  ageMax: 0,
  bodyShapes: [],
  singular: '',
  plural: ''
};

export default state;
