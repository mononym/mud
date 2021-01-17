defmodule MudWeb.CharacterView do
  use MudWeb, :view
  alias MudWeb.CharacterView
  alias MudWeb.CharacterSettingsView
  alias MudWeb.RaceView

  def render("character-creation-data.json", %{races: races}) do
    render_many(races, RaceView, "race.json")
  end

  def render("index.json", %{characters: characters}) do
    render_many(characters, CharacterView, "character.json")
  end

  def render("show.json", %{character: character}) do
    render_one(character, CharacterView, "character.json")
  end

  def render("character.json", %{character: character}) do
    character
    |> Map.from_struct()
    |> Map.delete(:area)
    |> Map.delete(:player)
    |> Map.delete(:skills)
    |> Map.delete(:held_items)
    |> Map.delete(:worn_items)
    |> Map.delete(:raw_skills)
    |> Map.delete(:maps)
    |> Map.delete(:__meta__)
    |> Map.put(
      :settings,
      render_one(
        character.settings,
        CharacterSettingsView,
        "character_settings.json"
      )
    )
    |> Recase.Enumerable.convert_keys(&Recase.to_camel/1)
  end
end
