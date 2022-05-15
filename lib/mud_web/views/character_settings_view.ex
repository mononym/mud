defmodule MudWeb.CharacterSettingsView do
  use MudWeb, :view
  alias MudWeb.CharacterSettingsView

  alias MudWeb.Views.Character.Settings.{
    AudioView,
    CommandsView,
    DirectionsWindowView,
    EnvironmentWindowView,
    StatusWindowView,
    MapWindowView,
    AreaWindowView,
    InventoryWindowView,
    ColorsView,
    PresetHotkeysView,
    CustomHotkeysView,
    EchoView
  }

  def render("show.json", %{character: character}) do
    render_one(character, CharacterSettingsView, "character_settings.json")
  end

  def render("character_settings.json", %{character_settings: settings}) do
    %{
      id: settings.id,
      character_id: settings.character_id,
      audio:
        render_one(
          settings.audio,
          AudioView,
          "audio.json"
        ),
      commands:
        render_one(
          settings.commands,
          CommandsView,
          "commands.json"
        ),
      directions_window:
        render_one(
          settings.directions_window,
          DirectionsWindowView,
          "directions_window.json"
        ),
      environment_window:
        render_one(
          settings.environment_window,
          EnvironmentWindowView,
          "environment_window.json"
        ),
      status_window:
        render_one(
          settings.status_window,
          StatusWindowView,
          "status_window.json"
        ),
      map_window:
        render_one(
          settings.map_window,
          MapWindowView,
          "map_window.json"
        ),
      area_window:
        render_one(
          settings.area_window,
          AreaWindowView,
          "area_window.json"
        ),
      inventory_window:
        render_one(
          settings.inventory_window,
          InventoryWindowView,
          "inventory_window.json"
        ),
      colors:
        render_one(
          settings.colors,
          ColorsView,
          "colors.json"
        ),
      preset_hotkeys:
        render_one(
          settings.preset_hotkeys,
          PresetHotkeysView,
          "preset_hotkeys.json"
        ),
      custom_hotkeys:
        render_many(
          settings.custom_hotkeys,
          CustomHotkeysView,
          "custom_hotkeys.json"
        ),
      echo:
        render_one(
          settings.echo,
          EchoView,
          "echo.json"
        )
    }
  end
end
