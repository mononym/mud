import { InstanceInterface } from '../instance/state';

export interface InstancesInterface {
  instances: Record<string, InstanceInterface>;
  instanceBeingBuilt: string;
}

const state: InstancesInterface = {
  instanceBeingBuilt: '',
  instances: {}
};

export default state;
