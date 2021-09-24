defmodule MudWeb.Views.Api.V1 do
  use MudWeb, :view

  def render("sync_player_characters.json", params) do
    %{
      characters: render_one(params.characters, MudWeb.CharacterView, "index.json"),
      player: render_one(params.player, MudWeb.PlayerView, "player.json")
    }
  end

  def render("physical_feature.json", %{physical_feature: physical_feature}) do
    %{
      birthDay: physical_feature.birth_day,
      birthSeason: physical_feature.birth_season,
      birthYear: physical_feature.birth_year,
      dominantHand: physical_feature.dominant_hand,
      eyeShape: physical_feature.eye_shape,
      eyeFeature: physical_feature.eye_feature,
      eyeColor: physical_feature.eye_color,
      hairColor: physical_feature.hair_color,
      hairFeature: physical_feature.hair_feature,
      hairLength: physical_feature.hair_length,
      hairStyle: physical_feature.hair_style,
      hairType: physical_feature.hair_type,
      skinTone: physical_feature.skin_tone,
      height: physical_feature.height,
      bodyType: physical_feature.body_type
    }
  end
end
