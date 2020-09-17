export interface LinkInterface {
  id: string;
  arrivalText: string;
  departureText: string;
  shortDescription: string;
  longDescription: string;
  icon: string;
  toId: string;
  fromId: string;
  insertedAt: string;
  updatedAt: string;
}

const state: LinkInterface = {
  id: '',
  arrivalText: '',
  departureText: '',
  shortDescription: '',
  longDescription: '',
  icon: '',
  toId: '',
  fromId: '',
  insertedAt: '',
  updatedAt: ''
};

export default state;
