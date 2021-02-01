export interface LinkClosableInterface {
  id: string;
  link_id: string;
  character_id: string;
  open: boolean;
  locked: boolean;
  owned: boolean;
}

const state: LinkClosableInterface = {
  id: "",
  link_id: "",
  character_id: "",
  open: false,
  locked: false,
  owned: false,
};

export default state;
