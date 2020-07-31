export interface PlayerInterface {
  id: string;
  status: string;
  tos_accepted: boolean;
}

const state: PlayerInterface = {
  id: '',
  status: '',
  tos_accepted: false
};

export default state;
