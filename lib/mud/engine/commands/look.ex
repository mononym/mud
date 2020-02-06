defmodule Mud.Engine.Command.Look do
  use Mud.Engine.CommandCallback

  alias Mud.Engine

  # @prepositions [
  #   "above",
  #   "across",
  #   "across from",
  #   "after",
  #   "against",
  #   "along",
  #   "alongside",
  #   "among",
  #   "at",
  #   "behind",
  #   "beside",
  #   "between",
  #   "beyond",
  #   "by",
  #   "except",
  #   "except for",
  #   "for",
  #   "following",
  #   "from",
  #   "in",
  #   "including",
  #   "inside",
  #   "into",
  #   "next to",
  #   "on",
  #   "ontop",
  #   "ontop of",
  #   "out",
  #   "over",
  #   "through",
  #   "towards",
  #   "under",
  #   "underneath",
  #   "up",
  #   "upon"
  # ]

  @impl true
  def parse_arg_string(raw_args) do
    # normalized_string =
    if String.starts_with?(raw_args, "at ") do
      {:ok, String.replace_leading(raw_args, "at ", "")}
    else
      {:ok, raw_args}
    end

    # normalized_string
    # gather all possible things to match, characters, items in the room, denizens, hostiles, etc...
    # order the

    # Engine.list_characters_in_area()
  end

  @impl true
  def execute(context) do
    output = build_output(context)

    context
    |> append_message(%Mud.Engine.Output{
      id: UUID.uuid4(),
      character_id: context.character_id,
      text: output
    })
    |> set_success(true)
  end

  def execute(name, context) do
    character = Engine.get_character!(context.character_id)
    characters = Engine.list_active_characters_in_areas(character.location_id)

    found_character =
      Enum.find(characters, fn character ->
        String.downcase(character.name) == name
      end)

    if found_character != nil do
      context
      |> append_message(%Mud.Engine.Output{
        id: UUID.uuid4(),
        character_id: context.character_id,
        text: "{{info}}You see #{found_character}.{{/info}}"
      })
      |> set_success(true)
    else
      context
      |> append_message(%Mud.Engine.Output{
        id: UUID.uuid4(),
        character_id: context.character_id,
        text: "{{error}}What did you want to look at?{{/error}}"
      })
      |> set_success(true)
    end
  end

  defp build_output(context) do
    area = Mud.Engine.get_area_from_character!(context.character_id)

    build_area_name(area)
    |> build_area_description(area)
    |> maybe_build_hostiles(area)
    |> maybe_build_denizens(area)
    |> maybe_build_also_present(area, context.character_id)
    |> maybe_build_obvious_exits(area)
  end

  defp build_area_name(area) do
    "{{area-name}}[#{area.name}]{{/area-name}}\n"
  end

  defp build_area_description(text, area) do
    text <> "{{area-description}}#{area.description}{{/area-description}}\n"
  end

  defp maybe_build_hostiles(text, _area) do
    # <> "{{hostiles}}Hostiles: #{player_characters}{{/hostiles}}\n"
    text
  end

  defp maybe_build_denizens(text, _area) do
    # <> "{{denizens}}Denizens: #{player_characters}{{/denizens}}\n"
    text
  end

  defp maybe_build_also_present(text, area, character_id) do
    also_present = build_player_characters_string(area.id, character_id)

    if also_present == "" do
      text
    else
      text <> "{{also-present}}Also Present: #{also_present}{{/also-present}}\n"
    end
  end

  defp maybe_build_obvious_exits(text, area) do
    obvious_exits = build_obvious_exits_string(area.id)

    if obvious_exits == "" do
      text
    else
      text <> "{{obvious-exits}}Obvious Exits: #{obvious_exits}{{/obvious-exits}}\n"
    end
  end

  defp build_obvious_exits_string(area_id) do
    Mud.Engine.list_obvious_exits(area_id)
    |> Enum.map(fn link ->
      link.departure_direction
    end)
    |> Enum.sort()
    |> Enum.join(", ")
  end

  # Character list should not contain the character the look is being performed for
  defp build_player_characters_string(area_id, character_id) do
    Mud.Engine.list_active_characters_in_areas(area_id)
    # filter out self
    |> Enum.filter(fn char ->
      char.id != character_id
    end)
    |> Enum.map(fn char ->
      char.name
    end)
    |> Enum.sort()
    |> Enum.join(", ")
  end
end
