export interface ItemContainerInterface {
  id: string;
  capacity: number;
  height: number;
  length: number;
  locked: boolean;
  open: boolean;
  width: number;
}

const state: ItemContainerInterface = {
  id: "",
  capacity: 1,
  height: 1,
  length: 1,
  locked: false,
  open: true,
  width: 1,
};

export default state;
