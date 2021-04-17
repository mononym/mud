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
    on_ground_label: string;
    base: string;
    echo: string;
    // Item Types
    furniture: string;
    equipment: string;
    weapon: string;
    armor: string;
    gem: string;
    coin: string;
    ammunition: string;
    shield: string;
    clothing: string;
    jewelry: string;
    structure: string;
    misc: string;

    // Link Types
    portal: string;
    closable: string;
    direction: string;
    object: string;

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
  audio: {
    id: string;
    music_volume: number;
    ambiance_volume: number;
    sound_effect_volume: number;
    play_music: boolean;
    play_ambiance: boolean;
    play_sound_effects: boolean;
  };
  directionsWindow: {
    id: string;
    active_direction_background_color: string;
    active_direction_icon_color: string;
    inactive_direction_background_color: string;
    inactive_direction_icon_color: string;
    background_color: string;
  };
  statusWindow: {
    id: string;
    posture_icon_color: string;
    background_color: string;
  };
  environmentWindow: {
    id: string;
    background_color: string;
    time_text_color: string;
  };
  mapWindow: {
    id: string;
    unexplored_link_color: string;
    background_color: string;
    highlighted_area_color: string;
  };
  presetHotkeys: {
    id: string;
    open_settings: string;
    open_play: string;
    toggle_history_view: string;
    zoom_map_out: string;
    zoom_map_in: string;
    select_cli: string;
  };
  echo: {
    id: string;
    cli_commands_in_story: boolean;
    hotkey_commands_in_story: boolean;
    ui_commands_in_story: boolean;
    ui_commands_replace_ids_in_story: boolean;
    cli_commands_in_logs: boolean;
    hotkey_commands_in_logs: boolean;
    ui_commands_in_logs: boolean;
    ui_commands_replace_ids_in_logs: boolean;
  };
  inventoryWindow: {
    id: string;
    empty_hand: string;
    held_items_label: string;
    show_held_items: boolean;
    worn_containers_label: string;
    show_worn_containers: boolean;
    worn_clothes_label: string;
    show_worn_clothes: boolean;
    worn_armor_label: string;
    show_worn_armor: boolean;
    worn_weapons_label: string;
    show_worn_weapons: boolean;
    worn_jewelry_label: string;
    show_worn_jewelry: boolean;
    worn_items_label: string;
    show_worn_items: boolean;
    slots_label: string;
    show_slots: boolean;
    background: string;
    filter_border_color: string;
    filter_active_icon_color: string;
    filter_inactive_icon_color: string;
    filter_active_background_color: string;
    filter_inactive_background_color: string;
    enabled_quick_action_color: string;
    disabled_quick_action_color: string;
    show_quick_actions: boolean;
  };
  areaWindow: {
    id: string;
    show_description: boolean;
    show_toi: boolean;
    show_on_ground: boolean;
    show_also_present: boolean;
    show_exits: boolean;
    background: string;
    description_expansion_mode: string;
    toi_expansion_mode: string;
    toi_collapse_threshold: number;
    on_ground_expansion_mode: string;
    on_ground_collapse_threshold: number;
    also_present_expansion_mode: string;
    also_present_collapse_threshold: number;
    exits_expansion_mode: string;
    exits_collapse_threshold: number;
    total_count_collapse_threshold: number;
    total_collapse_mode: string;
    filter_active_icon_color: string;
    filter_inactive_icon_color: string;
    filter_active_background_color: string;
    filter_inactive_background_color: string;
    filter_border_color: string;
    enabled_quick_action_color: string;
    disabled_quick_action_color: string;
    show_quick_actions: boolean;
  };
  customHotkeys: HotkeyInterface[];
  commands: {
    search_mode: string;
    multiple_matches_mode: string;
    say_requires_exact_emote: boolean;
  };
}

const state: CharacterSettingsInterface = {
  id: "",
  audio: {
    id: "",
    music_volume: 40,
    ambiance_volume: 50,
    sound_effect_volume: 60,
    play_music: true,
    play_ambiance: true,
    play_sound_effects: true,
  },
  directionsWindow: {
    id: "",
    active_direction_background_color: "",
    active_direction_icon_color: "",
    inactive_direction_background_color: "",
    inactive_direction_icon_color: "",
    background_color: "",
  },
  statusWindow: {
    id: "",
    posture_icon_color: "",
    background_color: "",
  },
  environmentWindow: {
    id: "",
    background_color: "",
    time_text_color: "",
  },
  areaWindow: {
    id: "",
    background: "#28282D",
    show_description: true,
    description_expansion_mode: "manual",

    show_toi: true,
    toi_expansion_mode: "manual-threshold",
    toi_collapse_threshold: 20,

    show_on_ground: true,
    on_ground_expansion_mode: "manual-threshold",
    on_ground_collapse_threshold: 20,

    show_also_present: true,
    also_present_expansion_mode: "manual-threshold",
    also_present_collapse_threshold: 20,

    show_exits: true,
    exits_expansion_mode: "manual-threshold",
    exits_collapse_threshold: 20,

    total_count_collapse_threshold: 50,
    total_collapse_mode: "largest",

    filter_border_color: "",
    filter_active_icon_color: "",
    filter_inactive_icon_color: "",
    filter_active_background_color: "",
    filter_inactive_background_color: "",
    enabled_quick_action_color: "",
    disabled_quick_action_color: "",
    show_quick_actions: true,
  },
  mapWindow: {
    id: "",
    unexplored_link_color: "",
    background_color: "",
    highlighted_area_color: "",
  },
  inventoryWindow: {
    id: "",
    empty_hand: "",
    held_items_label: "",
    show_held_items: true,
    worn_containers_label: "",
    show_worn_containers: true,
    worn_clothes_label: "",
    show_worn_clothes: true,
    worn_armor_label: "",
    show_worn_armor: true,
    worn_weapons_label: "",
    show_worn_weapons: true,
    worn_jewelry_label: "",
    show_worn_jewelry: true,
    worn_items_label: "",
    show_worn_items: true,
    slots_label: "",
    show_slots: true,
    background: "",
    filter_border_color: "",
    filter_active_icon_color: "",
    filter_inactive_icon_color: "",
    filter_active_background_color: "",
    filter_inactive_background_color: "",
    enabled_quick_action_color: "",
    disabled_quick_action_color: "",
    show_quick_actions: true,
  },
  echo: {
    id: "",
    cli_commands_in_story: true,
    hotkey_commands_in_story: true,
    ui_commands_in_story: true,
    ui_commands_replace_ids_in_story: true,
    cli_commands_in_logs: true,
    hotkey_commands_in_logs: true,
    ui_commands_in_logs: true,
    ui_commands_replace_ids_in_logs: true,
  },
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
    on_ground_label: "#ffffff",
    base: "#ffffff",
    echo: "#ffffff",
    // Item Types
    furniture: "#ffffff",
    equipment: "#ffffff",
    weapon: "#ffffff",
    armor: "#ffffff",
    gem: "#ffffff",
    coin: "#FFD700",
    jewelry: "#FFD700",
    structure: "#FFD700",
    ammunition: "#ffffff",
    shield: "#ffffff",
    clothing: "#ffffff",
    misc: "#ffffff",
    // Link Types
    portal: "#73A6E8",
    closable: "#E8B773",
    direction: "#9BD2EE",
    object: "#FFD700",
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
    select_cli: "CTRL + SHIFT + KeyC",
  },
  customHotkeys: [],
  commands: {
    search_mode: "simple",
    multiple_matches_mode: "full path",
    say_requires_exact_emote: false,
  },
};

export default state;
