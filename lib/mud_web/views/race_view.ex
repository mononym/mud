defmodule MudWeb.RaceView do
  use MudWeb, :view
  alias MudWeb.RaceView

  def render("index.json", %{races: races}) do
    render_many(races, RaceView, "race.json")
  end

  def render("show.json", %{race: race}) do
    render_one(race, RaceView, "race.json")
  end

  def render("race.json", %{race: race}) do
    %{
      singular: race.singular,
      plural: race.plural,
      adjective: race.adjective,
      eyeColors: race.eye_colors,
      eyeShapes: race.eye_shapes,
      eyeFeatures: race.eye_features,
      hairColors: race.hair_colors,
      hairTypes: race.hair_types,
      hairStyles: race.hair_styles,
      hairLengths: race.hair_lengths,
      heights: race.heights,
      skinTones: race.skin_tones,
      description: race.description,
      pronouns: race.pronouns,
      ageMin: race.age_min,
      ageMax: race.age_max,
      bodyTypes: race.body_types
    }
  end
end
