export interface CharacterSlotsInterface {
  id: string;
  character_id: string;
  on_back: number;
  around_waist: number;
  on_belt: number;
  on_finger: number;
  over_shoulders: number;
  over_shoulder: number;
  on_head: number;
  in_hair: number;
  on_hair: number;
  around_neck: number;
  on_torso: number;
  on_legs: number;
  on_feet: number;
  on_hands: number;
  on_thigh: number;
  on_ankle: number;
}

const state: CharacterSlotsInterface = {
  id: "",
  character_id: "",
  on_back: 0,
  around_waist: 0,
  on_belt: 0,
  on_finger: 0,
  over_shoulders: 0,
  over_shoulder: 0,
  on_head: 0,
  in_hair: 0,
  on_hair: 0,
  around_neck: 0,
  on_torso: 0,
  on_legs: 0,
  on_feet: 0,
  on_hands: 0,
  on_thigh: 0,
  on_ankle: 0,
};

export default state;
