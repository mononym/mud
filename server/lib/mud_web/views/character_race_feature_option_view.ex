defmodule MudWeb.CharacterRaceFeatureOptionView do
  use MudWeb, :view
  alias MudWeb.CharacterRaceFeatureOptionView

  def render("index.json", %{character_race_feature_option: character_race_feature_options}) do
    %{
      data:
        render_many(
          character_race_feature_options,
          CharacterRaceFeatureOptionView,
          "character_race_feature_option.json"
        )
    }
  end

  def render("show.json", %{character_race_feature_option: character_race_feature_option}) do
    %{
      data:
        render_one(
          character_race_feature_option,
          CharacterRaceFeatureOptionView,
          "character_race_feature_option.json"
        )
    }
  end

  def render("character_race_feature_option.json", %{
        character_race_feature_option: character_race_feature_option
      }) do
    %{
      id: character_race_feature_option.id,
      option: character_race_feature_option.option,
      conditions: character_race_feature_option.conditions
    }
  end
end
