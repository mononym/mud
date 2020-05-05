defmodule Mud.Engine.Command.Move do
  @moduledoc """
  The MOVE command moves a Character in a direction. This is usually an exit but can be other things.

  Syntax:
    - move < exit | direction >

  Aliases:
    - go
    - cardinal/ordinal directions
    - relative directions

  Examples:
    - move south
    - out
    - move bridge
    - move red door
    - move right
    - south
  """
  use Mud.Engine.CommandCallback

  require Logger

  import Mud.Engine.Util

  @impl true
  def execute(%Mud.Engine.CommandContext{} = context) do
    segments = context.command.segments

    cond do
      get_in(segments.children, [:exit]) != nil ->
        attempt_move(Enum.join(segments.children.exit.input, " "), context)

      List.first(segments.input) not in ["go", "move"] ->
        direction =
          List.first(segments.input)
          |> normalize_direction()

        attempt_move(direction, context)

      true ->
        help_docs = Mud.Util.get_module_docs(__MODULE__)

        context
        |> append_message(
          output(
            context.character_id,
            "{{help_docs}}#{help_docs}{{/help_docs}}"
          )
        )
        |> set_success()
    end
  end

  defp attempt_move(direction, context) do
    case Mud.Engine.find_obvious_exit_in_area(
           context.character.location_id,
           direction
         ) do
      [] ->
        append_message(
          context,
          %Mud.Engine.Output{
            id: context.id,
            character_id: context.character_id,
            text: "{{error}}You cannot travel in that direction.{{/error}}"
          }
        )

      [link] ->
        # IO.inspect(link)
        do_move(context, link)

      # TODO: MAKE THIS LOGIC LIKE LOOK LOGIC WITH MULTIPLE MATCHES
      # links here like object
      list_of_links when length(list_of_links) < 10 ->
        Logger.debug("Several Links found")
        obvious_directions = Stream.map(list_of_links, & &1.text)

        error =
          "{{warning}}Multiple matching exits were found. Please enter the number associated with the exit you wish to use.{{/warning}}"

        multiple_link_error(context, list_of_links, obvious_directions, error)

      _many ->
        Logger.debug("Many Links found")

        context
        |> append_message(
          output(
            context.character_id,
            "{{error}}Which Exit?{{/error}}"
          )
        )
        |> set_success()
    end
  end

  defp do_move(context, link) do
    # Move the character in the database
    {:ok, character} =
      context.character_id
      |> Mud.Engine.get_character!()
      |> Mud.Engine.update_character(%{location_id: link.to_id})

    # Perform look logic for character
    context_with_look_command =
      append_message(
        context,
        %Mud.Engine.Input{
          id: UUID.uuid4(),
          character_id: context.character_id,
          text: "look",
          type: :silent
        }
      )

    # List all the characters that need to be informed of a move
    characters_by_location =
      Mud.Engine.list_active_characters_in_areas([link.to_id, link.from_id])
      # Filter out "self"
      |> Enum.filter(fn char ->
        char.id != character.id
      end)
      # Group by location
      |> Enum.group_by(fn char ->
        char.location_id
      end)

    # Send messages to everyone in room that the character just left
    context_with_some_messages =
      Enum.reduce(
        characters_by_location[link.from_id] || [],
        context_with_look_command,
        fn char, ctx ->
          append_message(
            ctx,
            %Mud.Engine.Output{
              id: UUID.uuid4(),
              character_id: char.id,
              text:
                "{{info}}#{character.name} left the area heading #{link.departure_direction}.{{/info}}"
            }
          )
        end
      )

    # Send messages to everyone in room that the character is arriving in
    context_with_all_messages =
      Enum.reduce(
        characters_by_location[link.to_id] || [],
        context_with_some_messages,
        fn char, ctx ->
          append_message(
            ctx,
            %Mud.Engine.Output{
              id: UUID.uuid4(),
              character_id: char.id,
              text:
                "{{info}}#{character.name} has entered the area from #{link.arrival_direction}.{{info}}"
            }
          )
        end
      )

    context_with_all_messages
    |> Mud.Engine.Util.clear_continuation_from_context()
    |> set_success()
  end

  defp multiple_link_error(context, items, strings, error_message) do
    items =
      items
      |> Enum.map(&("move " <> &1.text))
      |> Mud.Util.list_to_index_map()

    context
    |> append_message(
      output(
        context.character_id,
        error_message,
        strings
      )
    )
    |> set_is_continuation(true)
    |> set_continuation_data(items)
    |> set_continuation_module(__MODULE__)
    |> set_continuation_type(:numeric)
    |> set_success()
  end

  defp normalize_direction(direction) do
    case direction do
      "nw" ->
        "northwest"

      "ne" ->
        "northeast"

      "n" ->
        "north"

      "e" ->
        "east"

      "w" ->
        "west"

      "s" ->
        "south"

      "sw" ->
        "southwest"

      "se" ->
        "southeast"

      "o" ->
        "out"

      "ou" ->
        "out"

      "i" ->
        "in"

      "u" ->
        "up"

      "d" ->
        "down"

      "do" ->
        "down"

      "dow" ->
        "down"

      _ ->
        direction
    end
  end
end
