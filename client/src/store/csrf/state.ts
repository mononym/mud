export interface CsrfInterface {
  token: string;
}

const state: CsrfInterface = {
  token: ''
};

export default state;
