defmodule Mud.Engine.Rules.PlayerRaces do
  defmodule Race do
    @derive Jason.Encoder
    defstruct singular: nil,
              plural: nil,
              adjective: nil,
              portrait: "",
              description: "",
              eye_colors: [],
              eye_shapes: [],
              eye_features: [],
              hair_colors: [],
              hair_types: [],
              hair_styles: [],
              hair_lengths: [],
              heights: [],
              skin_tones: [],
              pronouns: [],
              age_min: 0,
              age_max: 0,
              body_shapes: []
  end

  def races do
    [
      human_race(),
      elven_race(),
      dwarfen_race()
    ]
    |> Enum.into(%{}, &{&1.singular, &1})
  end

  defp human_race do
    %Race{
      singular: "Human",
      plural: "Humans",
      adjective: "Human",
      portrait: "human_portrait_1_small.jpg",
      description:
        "The most numerous of the young races, Humans can be found almost everywhere there is civilization, and many places where there is none. They are also the most adaptable of all the races, and can be found engaging and excelling in every profession.",
      eye_colors: common_eye_colors(),
      eye_shapes: common_eye_shapes(),
      eye_features: common_eye_features(),
      skin_tones: common_skin_tones(),
      hair_lengths: common_hair_lengths(),
      hair_colors: common_hair_colors(),
      hair_types: common_hair_types(),
      hair_styles: common_hair_styles(),
      heights: common_heights(),
      pronouns: common_pronouns(),
      body_shapes: common_body_shapes(),
      age_min: 18,
      age_max: 60
    }
  end

  defp elven_race do
    %Race{
      singular: "Elf",
      plural: "Elfs",
      adjective: "Elven",
      portrait: "human_portrait_1_small.jpg",
      description:
        "The oldest and longest lived of the old races, Elves are often haughty when dealing with those they consider to be lesser than them. Which is often everyone.",
      eye_colors: common_eye_colors(),
      eye_shapes: common_eye_shapes(),
      eye_features: common_eye_features(),
      skin_tones: common_skin_tones(),
      hair_lengths: common_hair_lengths(),
      hair_colors: common_hair_colors(),
      hair_types: common_hair_types(),
      hair_styles: common_hair_styles(),
      heights: common_heights(),
      pronouns: common_pronouns(),
      body_shapes: common_body_shapes(),
      age_min: 50,
      age_max: 120
    }
  end

  defp dwarfen_race do
    %Race{
      singular: "Dwarf",
      plural: "Dwarves",
      adjective: "Dwarven",
      portrait: "human_portrait_1_small.jpg",
      description: "Second only to Elves in lifespan, Dwarfen kind couldn't be more different.",
      eye_colors: common_eye_colors(),
      eye_shapes: common_eye_shapes(),
      eye_features: common_eye_features(),
      skin_tones: common_skin_tones(),
      hair_lengths: common_hair_lengths(),
      hair_colors: common_hair_colors(),
      hair_types: common_hair_types(),
      hair_styles: common_hair_styles(),
      heights: common_heights(),
      pronouns: common_pronouns(),
      body_shapes: common_body_shapes(),
      age_min: 40,
      age_max: 100
    }
  end

  defp common_body_shapes do
    [
      "thin",
      "skinny",
      "rail thin",
      "svelte",
      "lissome",
      "blocky",
      "rotund",
      "bulging",
      "athletic",
      "flabby",
      "round",
      "pear shaped",
      "hourglass",
      "curvy",
      "soft",
      "hard",
      "muscular",
      "wirey",
      "scrawney",
      "bulky"
    ]
    |> Enum.sort()
  end

  defp common_pronouns do
    ["male", "female", "neutral"]
    |> Enum.sort()
  end

  defp common_eye_colors do
    [
      # amber
      "amber",
      "dark amber",
      "light amber",
      "black",
      # blue
      "blue",
      "sky blue",
      "dark blue",
      "light blue",
      "brown",
      "green",
      "leaf green",
      "silver",
      "sea green",
      "dark brown",
      "light brown",
      "yellow",
      "emerald green",
      "silvery white"
    ]
    |> Enum.sort()
  end

  defp common_skin_tones do
    [
      "deeply tanned",
      "almost transparent",
      "milky white",
      "tanned",
      "tan",
      "dark tan",
      "light tan",
      "lightly tanned",
      "pale",
      "slightly pale",
      "very pale",
      "dark",
      "brown",
      "light brown",
      "dark brown",
      "black",
      "ebony",
      "ivory"
    ]
    |> Enum.sort()
  end

  defp common_eye_features do
    [
      "shiny",
      "dull",
      "sparkling",
      "glistening",
      "clear",
      "cloudy",
      "dead",
      "lively",
      "shimmering",
      "darting",
      "beady",
      "piercing"
    ]
    |> Enum.sort()
  end

  defp common_eye_size do
    ["big", "average", "small"]
    |> Enum.sort()
  end

  defp common_eye_placement do
    [
      "average",
      "wide set",
      "asymmetrical",
      "big",
      "small",
      "close set",
      "deep set",
      "downturned",
      "upturned",
      "protruding"
    ]
    |> Enum.sort()
  end

  defp common_eye_shapes do
    ["oval", "almond", "round", "monolid", "hooded"]
    |> Enum.sort()
  end

  defp common_heights do
    ["short", "very short", "average", "tall", "very tall"]
    |> Enum.sort()
  end

  defp common_hair_colors do
    [
      "blonde",
      "strawberry blonde",
      "dirty blonde",
      "platinum blonde",
      "gold",
      "golden",
      "golden blonde",
      "flaxen",
      "ash blonde",
      "sandy blonde",
      "venetian blonde",
      "reddish blonde",
      "cream-colored blonde",
      "grayish blonde",
      "whitish blonde",
      "honey blonde",
      "black",
      "brown",
      "brunette",
      "auburn",
      "chestnut",
      "lightbrown",
      "dark brown",
      "silver",
      "white",
      "gray",
      "light gray",
      "dark gray",
      "salt and pepper",
      "silvery",
      "towhaired",
      "light red",
      "dark red",
      "ginger red",
      "titian",
      "light titian",
      "dark titian",
      "light copper",
      "copper",
      "dark copper",
      "red"
    ]
    |> Enum.sort()
  end

  defp common_hair_types do
    [
      "straight",
      "almost straight",
      "wavy",
      "curly",
      "slightly curly",
      "slightly wavy",
      "very curly",
      "tightly curled",
      "loosely curled",
      "very wavy"
    ]
    |> Enum.sort()
  end

  [%{"style" => "worn in a simple, loose style", "lengths" => ["short", "very short"]}]

  defp common_hair_styles do
  end

  defp common_hair_lengths do
    [
      "short",
      "very short",
      "bald",
      "closely cut",
      "pixie cut",
      "long",
      "very long",
      "shoulder length",
      "hip length",
      "mid back"
    ]
    |> Enum.sort()
  end

  def list_race_names do
    Enum.map(races(), & &1.name)
  end

  def list_races do
    races()
  end

  def get_race_by_name(name) do
    case Enum.find(races(), fn race -> race.name == name end) do
      nil -> {:error, :not_found}
      race -> {:ok, race}
    end
  end
end
