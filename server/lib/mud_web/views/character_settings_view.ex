defmodule MudWeb.CharacterSettingsView do
  use MudWeb, :view
  alias MudWeb.CharacterSettingsView

  def render("show.json", %{character: character}) do
    render_one(character, CharacterSettingsView, "character_settings.json")
  end

  def render("character_settings.json", %{character_settings: character_settings}) do
    character_settings
    |> Map.from_struct()
    |> Map.delete(:__meta__)
    |> Map.delete(:character)
    # |> Recase.Enumerable.convert_keys(&Recase.to_camel/1)
  end
end
