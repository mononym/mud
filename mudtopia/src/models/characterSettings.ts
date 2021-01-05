import type { HotkeyInterface } from "./hotkey";

export interface CharacterSettingsInterface {
  id: string;
  textColors: {
    id: string;
    system_warning: string;
    system_alert: string;
    area_name: string;
    area_description: string;
    character: string;
    furniture: string;
    exit: string;
    denizen: string;
  };
  presetHotkeys: {
    id: string;
    open_settings: string;
  };
  customHotkeys: HotkeyInterface[];
}

const state: CharacterSettingsInterface = {
  id: "",
  textColors: {
    id: "",
    system_warning: "#f0ad4e",
    system_alert: "#d9534f",
    area_name: "#ffffff",
    area_description: "#ffffff",
    character: "#ffffff",
    furniture: "#ffffff",
    exit: "#ffffff",
    denizen: "#ffffff",
  },
  presetHotkeys: {
    id: "",
    open_settings: "CTRL+SHIFT+s",
  },
  customHotkeys: [],
};

export default state;
