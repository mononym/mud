defmodule MudWeb.CharacterRaceFeatureView do
  use MudWeb, :view
  alias MudWeb.CharacterRaceFeatureView

  def render("index.json", %{character_race_feature: character_race_feature}) do
    render_many(
      character_race_feature,
      CharacterRaceFeatureView,
      "character_race_feature.json"
    )
  end

  def render("show.json", %{character_race_feature: character_race_feature}) do
    render_one(
      character_race_feature,
      CharacterRaceFeatureView,
      "character_race_feature.json"
    )
  end

  def render("character_race_feature.json", %{character_race_feature: character_race_feature}) do
    %{
      id: character_race_feature.id,
      name: character_race_feature.name,
      key: character_race_feature.key,
      field: character_race_feature.field,
      type: character_race_feature.type,
      options: character_race_feature.options
    }
  end
end
