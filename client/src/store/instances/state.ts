import { InstanceInterface } from '../instance/state';

export interface InstancesInterface {
  instances: Record<string, InstanceInterface>;
}

const state: InstancesInterface = {
  instances: {}
};

export default state;
