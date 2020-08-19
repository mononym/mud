import { InstanceInterface } from '../instance/state';

export interface InstancesInterface {
  instances: Record<string, InstanceInterface>;
}

const state: InstancesInterface = {
  instances: {
    'prime': {id: 'prime', status: 'up', name: 'Prime', description: 'The most populated instance. Roleplay is lightly enforced, meaning at a minimum you cannot break the immersion of other players while you are not forced to engage yourself.'},
    'premium': {id: 'premium', status: 'down', name: 'Premium', description: 'With a small but highly dedicated roleplay community, Premium is the place to be if you value the quality of the roleplay experience over the quantity. Roleplay is heavily enforced.'}
  }
};

export default state;
