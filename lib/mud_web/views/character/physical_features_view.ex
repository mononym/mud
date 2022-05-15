defmodule MudWeb.Views.Character.PhysicalFeaturesView do
  use MudWeb, :view

  def render("physical_features.json", %{physical_features: physical_features}) do
    render_many(physical_features, __MODULE__, "physical_feature.json")
  end

  def render("physical_feature.json", %{physical_features: physical_feature}) do
    %{
      id: physical_feature.id,
      character_id: physical_feature.character_id,
      birth_day: physical_feature.birth_day,
      birth_season: physical_feature.birth_season,
      birth_year: physical_feature.birth_year,
      dominant_hand: physical_feature.dominant_hand,
      eye_shape: physical_feature.eye_shape,
      eye_feature: physical_feature.eye_feature,
      eye_color: physical_feature.eye_color,
      hair_color: physical_feature.hair_color,
      hair_feature: physical_feature.hair_feature,
      hair_length: physical_feature.hair_length,
      hair_style: physical_feature.hair_style,
      hair_type: physical_feature.hair_type,
      skin_tone: physical_feature.skin_tone,
      height: physical_feature.height,
      body_type: physical_feature.body_type
    }
  end
end
