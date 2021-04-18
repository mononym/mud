export interface LinkFlagsInterface {
  id: string;
  link_id: string;
  closable: boolean;
  portal: boolean;
  direction: boolean;
  object: boolean;
  sound_travels_when_open: boolean;
  sound_travels_when_closed: boolean;
}

const state: LinkFlagsInterface = {
  id: "",
  link_id: "",
  closable: false,
  portal: false,
  direction: true,
  object: false,
  sound_travels_when_open: true,
  sound_travels_when_closed: false,
};

export default state;
