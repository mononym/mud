export interface HotkeyInterface {
  id: string;
  ctrlKey: boolean;
  altKey: boolean;
  shiftKey: boolean;
  metaKey: boolean;
  key: string;
  command: string;
}

const state: HotkeyInterface = {
  id: "",
  ctrlKey: false,
  altKey: false,
  shiftKey: false,
  metaKey: false,
  key: "",
  command: "",
};

export default state;
