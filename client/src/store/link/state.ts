export interface LinkInterface {
  id: string;
  arrivalText: string;
  departureText: string;
  shortDescription: string;
  longDescription: string;
  type: string;
  icon: string;
  toId: string;
  fromId: string;
}

const state: LinkInterface = {
  id: '',
  arrivalText: '',
  departureText: '',
  shortDescription: '',
  longDescription: '',
  icon: '',
  type: '',
  toId: '',
  fromId: '',
};

export default state;
