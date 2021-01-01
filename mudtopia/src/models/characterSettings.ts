export interface CharacterSettingsInterface {
  id: string;
  system_warning_text_color: string;
  system_alert_text_color: string;
  area_name_text_color: string;
  area_description_text_color: string;
  character_text_color: string;
  furniture_text_color: string;
  exit_text_color: string;
  denizen_text_color: string;
}

const state: CharacterSettingsInterface = {
  id: "",
  system_warning_text_color: "#FFFFFF",
  system_alert_text_color: "#FFFFFF",
  area_name_text_color: "#FFFFFF",
  area_description_text_color: "#FFFFFF",
  character_text_color: "#FFFFFF",
  furniture_text_color: "#FFFFFF",
  exit_text_color: "#FFFFFF",
  denizen_text_color: "#FFFFFF",
};

export default state;
