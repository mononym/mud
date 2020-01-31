defmodule Mud.Engine.Command.Look do
  use Mud.Engine.CommandCallback

  def execute(context) do
    area = Mud.Engine.get_area_from_character!(context.character_id)

    obvious_exits = build_obvious_exits_string(area.id)

    player_characters = build_player_characters_string(area.id)

    context
    |> append_message(%Mud.Engine.OutputMessage{
      character_id: context.character_id,
      text:
        "{{area-name}}[#{area.name}]{{/area-name}}\n" <>
          "{{area-description}}#{area.description}{{/area-description}}\n" <>
          "{{also-present}}Also Present: #{player_characters}{{/also-present}}\n" <>
          "{{obvious-exits}}Obvious Exits: #{obvious_exits}{{/obvious-exits}}"
    })
    |> set_success(true)
  end

  defp build_obvious_exits_string(area_id) do
    Mud.Engine.list_obvious_exits(area_id)
    |> Enum.map(fn link ->
      link.departure_direction
    end)
    |> Enum.sort()
    |> Enum.join(", ")
  end

  defp build_player_characters_string(area_id) do
    Mud.Engine.list_characters_in_areas(area_id)
    |> Enum.map(fn char ->
      char.name
    end)
    |> Enum.sort()
    |> Enum.join(", ")
  end
end
