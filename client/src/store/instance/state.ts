export interface InstanceInterface {
  id: string;
  status: string;
  name: string;
  description: string;
}

const state: InstanceInterface = {
  id: '',
  status: '',
  name: '',
  description: ''
};

export default state;
