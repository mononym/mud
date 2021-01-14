import type { HotkeyInterface } from "./hotkey";

export interface CharacterSettingsInterface {
  id: string;
  colors: {
    id: string;
    // Text colors
    system_warning: string;
    system_info: string;
    system_alert: string;
    area_name: string;
    area_description: string;
    character: string;
    exit: string;
    denizen: string;
    denizen_label: string;
    toi_label: string;
    exit_label: string;
    character_label: string;
    base: string;
    // Item Types
    furniture: string;
    container: string;
    worn_container: string;
    weapon: string;
    armor: string;
    gem: string;
    coin: string;
    ammunition: string;
    shield: string;
    clothing: string;
    // Command Input window colors
    input: string;
    input_background: string;
    input_button_background: string;
    input_button_icon: string;
    // Story window colors
    story_background: string;
    story_history_icon: string;
    story_history_border: string;
    // UI colors
    window_toolbar_background: string;
    window_toolbar_label: string;
    window_lock_unlocked: string;
    window_lock_locked: string;
    window_move_unlocked: string;
    window_move_locked: string;
  };
  presetHotkeys: {
    id: string;
    open_settings: string;
    open_play: string;
    toggle_history_view: string;
    zoom_map_out: string;
    zoom_map_in: string;
  };
  customHotkeys: HotkeyInterface[];
}

const state: CharacterSettingsInterface = {
  id: "",
  colors: {
    id: "",
    // Text colors
    system_warning: "#f0ad4e",
    system_info: "#d9534f",
    system_alert: "#d9534f",
    area_name: "#ffffff",
    area_description: "#ffffff",
    character: "#ffffff",
    exit: "#ffffff",
    denizen: "#ffffff",
    denizen_label: "#ffffff",
    toi_label: "#ffffff",
    exit_label: "#ffffff",
    character_label: "#ffffff",
    base: "#ffffff",
    // Item Types
    furniture: "#ffffff",
    container: "#ffffff",
    worn_container: "#ffffff",
    weapon: "#ffffff",
    armor: "#ffffff",
    gem: "#ffffff",
    coin: "#ffffff",
    ammunition: "#ffffff",
    shield: "#ffffff",
    clothing: "#ffffff",
    // Command Input window colors
    input: "#000000",
    input_background: "#ffffff",
    input_button_background: "#ffffff",
    input_button_icon: "#ffffff",
    // Story window colors
    story_background: "#ffffff",
    story_history_icon: "#ffffff",
    story_history_border: "#ffffff",
    // UI colors
    window_toolbar_background: "#ffffff",
    window_toolbar_label: "#ffffff",
    window_lock_unlocked: "#ffffff",
    window_lock_locked: "#ffffff",
    window_move_unlocked: "#ffffff",
    window_move_locked: "#ffffff",
  },
  presetHotkeys: {
    id: "",
    open_settings: "CTRL + SHIFT + KeyS",
    open_play: "CTRL + SHIFT + KeyP",
    toggle_history_view: "CTRL + SHIFT + KeyH",
    zoom_map_out: "CTRL + SHIFT + Minus",
    zoom_map_in: "CTRL + SHIFT + Equals",
  },
  customHotkeys: [],
};

export default state;
