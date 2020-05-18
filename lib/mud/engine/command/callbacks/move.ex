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
  alias Mud.Engine.Command.ExecutionContext
  alias Mud.Engine.Model.{Character, Area}
  alias Mud.Engine.Search
  alias Mud.Engine.Util

  use Mud.Engine.Command.Callback

  @impl true
  def continue(%ExecutionContext{} = context) do
    attempt_move(context.input.match, context)
  end

  @impl true
  def execute(%ExecutionContext{} = context) do
    segment = context.command.segments

    which_target =
      if segment[:number] != nil do
        min(1, segment[:number][:input])
      else
        0
      end

    cond do
      segment.input not in ["go", "move"] ->
        direction =
          segment.input
          |> normalize_direction()

        attempt_move(direction, context, which_target)

      get_in(segment, [:exit, :input]) != nil ->
        attempt_move(get_in(segment, [:exit, :input]), context, which_target)

      true ->
        help_docs = Util.get_module_docs(__MODULE__)

        context
        |> append_message(
          Util.output(
            context.character_id,
            "{{help_docs}}#{help_docs}{{/help_docs}}"
          )
        )
        |> set_success()
    end
  end

  defp attempt_move(link, context) do
    if link.from_id == context.character.area_id do
      maybe_move(context, link)
    else
      context
      |> append_message(
        Util.output(
          context.character_id,
          "{{error}}Unfortunately, your desired direction of travel is no longer possible.{{/error}}"
        )
      )
      |> set_success()
    end
  end

  defp attempt_move(direction, context, which_target) do
    matches =
      Search.find_obvious_exits_in_area(context.character.area_id, direction, context.character)

    num_exact_matches = length(matches.exact_matches)
    num_partial_matches = length(matches.partial_matches)

    # NOTE: The 'duplicate' logic here is intentional. DO NOT REFACTOR UNLESS YOU ARE SURE OF WHAT YOU ARE DOING!
    #
    # Desired behaviour is that if there are exact matches, they should be handled as if there were no partial matches.
    cond do
      # happy path with a single match with no index chosen
      num_exact_matches == 1 and which_target == 0 ->
        match = List.first(matches.exact_matches)

        maybe_move(context, match.match)

      # happy path where there are matches, and chosen index is in range
      num_exact_matches > 1 and which_target > 0 and which_target <= num_exact_matches ->
        match = Enum.at(matches.exact_matches, which_target - 1)

        maybe_move(context, match.match)

      # unhappy path where there are multiple matches
      num_exact_matches > 1 and which_target == 0 ->
        handle_multiple_matches(context, matches.exact_matches)

      # happy path with a single match with no index chosen
      num_partial_matches == 1 and which_target == 0 ->
        match = List.first(matches.partial_matches)

        maybe_move(context, match.match)

      # happy path where there are matches, and chosen index is in range
      num_partial_matches > 1 and which_target > 0 and which_target <= num_partial_matches ->
        match = Enum.at(matches.partial_matches, which_target - 1)

        maybe_move(context, match.match)

      # unhappy path where there are multiple matches
      num_partial_matches > 1 and which_target == 0 ->
        handle_multiple_matches(context, matches.partial_matches)

      # unhappy path where there are multiple matches or no matches at all
      true ->
        error_msg = "{{warning}}You cannot travel in that direction.{{/warning}}"

        ExecutionContext.success_with_output(context, context.character.id, error_msg, "error")
    end
  end

  defp handle_multiple_matches(context, matches) when length(matches) < 10 do
    descriptions = Enum.map(matches, & &1.glance_description)

    error_msg = "{{warning}}Which exit?{{/warning}}"

    Util.multiple_match_error(context, descriptions, matches, error_msg, __MODULE__)
  end

  defp handle_multiple_matches(context, _matches) do
    error_msg = "Found too many exits. Please be more specific."

    ExecutionContext.success_with_output(context, context.character.id, error_msg, "error")
  end

  defp maybe_move(context, link) do
    char = context.character

    if char.position == "standing" do
      move(context, link)
    else
      error_msg = "You must be standing before you can move."

      ExecutionContext.success_with_output(context, context.character.id, error_msg, "error")
    end
  end

  defp move(context, link) do
    # Move the character in the database
    {:ok, character} = Character.update(context.character, %{area_id: link.to_id})

    # Perform look logic for character
    context_with_look_command =
      ExecutionContext.add_output(
        context,
        context.character_id,
        Area.describe_look(link.to_id, context.character)
      )

    # List all the characters that need to be informed of a move
    characters_by_area =
      Character.list_others_active_in_areas(character, [link.to_id, link.from_id])
      # Group by location
      |> Enum.group_by(fn char ->
        char.area_id
      end)

    # Send messages to everyone in room that the character just left
    context_with_some_messages =
      ExecutionContext.add_output(
        context_with_look_command,
        characters_by_area[link.from_id] || [],
        "#{character.name} left the area heading #{link.departure_direction}.",
        "info"
      )

    # Send messages to everyone in room that the character is arriving in
    context_with_all_messages =
      ExecutionContext.add_output(
        context_with_some_messages,
        characters_by_area[link.from_id] || [],
        "#{character.name} has entered the area from #{link.arrival_direction}.",
        "info"
      )

    context_with_all_messages
    |> Util.clear_continuation_from_context()
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
