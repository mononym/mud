defmodule MudWeb.CharacterView do
  use MudWeb, :view
  alias MudWeb.CharacterView
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
    %{
      id: character.id,
      agility: character.agility,
      charisma: character.charisma,
      constitution: character.constitution,
      dexterity: character.dexterity,
      intelligence: character.intelligence,
      reflexes: character.reflexes,
      slug: character.slug,
      stamina: character.stamina,
      strength: character.strength,
      wisdom: character.wisdom,
      age: character.age,
      eyeColor: character.eye_color,
      eyeColorType: character.eye_color_type,
      eyeAccentColor: character.eye_accent_color,
      hairColor: character.hair_color,
      hairLength: character.hair_length,
      hairStyle: character.hair_style,
      race: character.race,
      skinColor: character.skin_color,
      height: character.height,
      handedness: character.handedness,
      position: character.position
    }
  end
end
