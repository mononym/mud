export interface InstanceInterface {
  id: string;
  status: string;
  name: string;
  slug: string;
  description: string;
}

const state: InstanceInterface = {
  id: '',
  status: '',
  name: '',
  slug: '',
  description: ''
};

export default state;
