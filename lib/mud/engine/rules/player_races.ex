defmodule Mud.Engine.Rules.PlayerRaces do
  defmodule Race do
    defstruct name: nil,
              eye_colors: [],
              hair_colors: [],
              skin_colors: [],
              portrait: "",
              description: ""
  end

  defp races do
    [
      human_race(),
      elven_race(),
      dwarfen_race()
    ]
  end

  defp human_race do
    %Race{
      name: "Human",
      portrait: "human_portrait_1_small.jpg",
      description:
        "The most numerous of the young races, Humans can be found almost everywhere there is civilization, and many places where there is none. They are also the most adaptable of all the races, and can be found engaging and excelling in every profession.",
      eye_colors: ["black", "blue", "brown", "green"],
      skin_colors: ["dark", "pale", "tan"],
      hair_colors: [
        "blonde",
        "strawberry-blonde",
        "black",
        "brown",
        "silver",
        "white",
        "salt-and-pepper"
      ]
    }
  end

  defp elven_race do
    %Race{
      name: "Elf",
      portrait: "human_portrait_1_small.jpg",
      description:
        "The oldest and longest lived of the old races, Elves are often haughty when dealing with those they consider to be lesser than them. Which is often everyone.",
      eye_colors: ["silver", "amber", "sea-green", "sky-blue"],
      skin_colors: ["deeply-tanned", "almost-transparent", "milky-white"],
      hair_colors: ["platinum-blonde", "light-brown", "brown", "silver", "white"]
    }
  end

  defp dwarfen_race do
    %Race{
      name: "Dwarf",
      portrait: "human_portrait_1_small.jpg",
      description: "Second only to Elves in lifespan, Dwarfen kind couldn't be more different.",
      eye_colors: ["brown", "dark-brown", "earthen-brown", "light-brown"],
      skin_colors: ["deeply-tanned", "tan"],
      hair_colors: ["dark-brown", "light-brown", "brown", "black", "salt-and-pepper", "white"]
    }
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
