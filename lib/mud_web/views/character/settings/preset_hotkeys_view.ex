defmodule MudWeb.Views.Character.Settings.PresetHotkeysView do
  use MudWeb, :view

  def render("preset_hotkeys.json", %{preset_hotkeys: preset_hotkeys}) do
    %{
      id: preset_hotkeys.id,
      select_cli: preset_hotkeys.select_cli,
      open_play: preset_hotkeys.open_play,
      open_settings: preset_hotkeys.open_settings,
      toggle_history_view: preset_hotkeys.toggle_history_view,
      zoom_map_out: preset_hotkeys.zoom_map_out,
      zoom_map_in: preset_hotkeys.zoom_map_in
    }
  end
end
