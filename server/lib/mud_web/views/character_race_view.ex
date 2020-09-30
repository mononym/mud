defmodule MudWeb.CharacterRaceView do
  use MudWeb, :view
  alias MudWeb.CharacterRaceView

  def render("index.json", %{character_races: character_races}) do
    %{data: render_many(character_races, CharacterRaceView, "character_race.json")}
  end

  def render("show.json", %{character_race: character_race}) do
    %{data: render_one(character_race, CharacterRaceView, "character_race.json")}
  end

  def render("character_race.json", %{character_race: character_race}) do
    %{id: character_race.id,
      singular: character_race.singular,
      plural: character_race.plural,
      adjective: character_race.adjective,
      portrait: character_race.portrait,
      description: character_race.description}
  end
end
