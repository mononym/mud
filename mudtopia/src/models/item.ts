export interface ItemInterface {
  id: string;
  areaId: string;
  isHidden: boolean;
  isFurniture: boolean;
  isScenery: boolean;
  shortDescription: string;
  longDescription: string;
  containerId: string;
  isContainer: boolean;
  containerCloseable: boolean;
  containerOpen: boolean;
  containerLockable: boolean;
  containerLocked: boolean;
  containerLength: number;
  containerWidth: number;
  containerHeight: number;
  containerCapacity: number;
  containerPrimary: boolean;
  isWearable: boolean;
  wearableIsWorn: boolean;
  wearableLocation: string;
  wearableWornById: string;
  isHoldable: boolean;
  holdableIsHeld: boolean;
  holdableHand: string;
  holdableHeldById: string;
  icon: string;
}

const state: ItemInterface = {
  id: "",
  areaId: "",
  isHidden: false,
  isFurniture: false,
  isScenery: false,
  shortDescription: "",
  longDescription: "",
  containerId: "",
  isContainer: false,
  containerCloseable: false,
  containerOpen: false,
  containerLockable: false,
  containerLocked: false,
  containerLength: 0,
  containerWidth: 0,
  containerHeight: 0,
  containerCapacity: 0,
  containerPrimary: false,
  isWearable: false,
  wearableIsWorn: false,
  wearableLocation: "",
  wearableWornById: "",
  isHoldable: false,
  holdableIsHeld: false,
  holdableHand: "",
  holdableHeldById: "",
  icon: "",
};

export default state;
