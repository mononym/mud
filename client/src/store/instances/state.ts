import { InstanceInterface } from '../instance/state';

export interface InstancesInterface {
  loaded: boolean;
  instances: InstanceInterface[];
  instanceIndex: Record<string, number>;
  instanceSlugIndex: Record<string, number>;
  instanceBeingBuilt: string;
}

const state: InstancesInterface = {
  instances: [],
  instanceIndex: {},
  instanceSlugIndex: {},
  loaded: false,
  instanceBeingBuilt: ''
};

export default state;
