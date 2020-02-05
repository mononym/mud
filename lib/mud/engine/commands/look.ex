defmodule Mud.Engine.Command.Look do
  use Mud.Engine.CommandCallback

  @prepositions [
    "about",
    "above",
    "across",
    "acrossfrom",
    "across from",
    "after",
    "against",
    "along",
    "alongside",
    "among",
    "at",
    "before",
    "behind",
    "beside",
    "between",
    "beyond",
    "but",
    "by",
    "concerning",
    "despite",
    "except",
    "exceptfor",
    "except for",
    "for",
    "following",
    "from",
    "in",
    "including",
    "inside",
    "into",
    "like",
    "of",
    "nextto",
    "next to",
    "on",
    "ontop",
    "ontopof",
    "ontop of",
    "out",
    "over",
    "plus",
    "since",
    "through",
    "throughout",
    "to",
    "towards",
    "under",
    "underneath",
    "until",
    "up",
    "upon",
    "with",
    "within",
    "without",
  ]

  def parse_arg_string(raw_args) do
    raw_args
    |> Mud.Util.replace_switches_with_prepositions(%{"@" => "at"})
    |> Mud.Engine.Command.parse_input()
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
