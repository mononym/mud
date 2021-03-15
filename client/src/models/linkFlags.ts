export interface LinkFlagsInterface {
  id: string;
  link_id: string;
  closable: boolean;
  portal: boolean;
  direction: boolean;
  object: boolean;
}

const state: LinkFlagsInterface = {
  id: "",
  link_id: "",
  closable: false,
  portal: false,
  direction: true,
  object: false,
};

export default state;
