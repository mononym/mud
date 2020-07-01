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
  alias Mud.Engine.{Character, Area, Link}
  alias Mud.Engine.Event.Client.{UpdateArea, UpdateCharacter}
  alias Mud.Engine.Search
  alias Mud.Engine.Util
  alias Mud.Engine.Message

  use Mud.Engine.Command.Callback

  @spec build_ast([Mud.Engine.Command.AstNode.t(), ...]) ::
          Mud.Engine.Command.AstNode.OneThing.t()
  def build_ast(ast_nodes) do
    Mud.Engine.Command.AstUtil.build_one_thing_ast(ast_nodes)
  end

  # @impl true
  # def continue(%ExecutionContext{} = context) do
  #   attempt_move(context.input.match, context)
  # end

  @impl true
  def execute(%ExecutionContext{} = context) do
    ast = context.command.ast

    cond do
      ast.command in ["go", "move"] and is_nil(ast.thing) ->
        ExecutionContext.append_output(
          context,
          context.character.id,
          "{{help_docs}}#{Util.get_module_docs(__MODULE__)}{{/help_docs}}",
          "error"
        )
        |> ExecutionContext.set_success()

      ast.command not in ["go", "move"] ->
        direction =
          ast.move
          |> normalize_direction()

        attempt_move_direction(direction, context, 0)

      true ->
        if Util.is_uuid4(ast.thing.input) do
          link = Link.get!(ast.thing.input)

          if link.from_id == context.character.area_id do
            attempt_move_link(context, link)
          else
            ExecutionContext.append_output(
              context,
              context.character.id,
              "{{error}}I'm sorry #{context.character.name}, I'm afraid I can't do that.{{/error}}",
              "error"
            )
            |> ExecutionContext.set_success()
          end
        else
          attempt_move_direction(ast.thing.input, context, ast.thing.which)
        end
    end
  end

  # defp attempt_move(link, context) do
  #   if link.from_id == context.character.area_id do
  #     maybe_move(context, link)
  #   else
  #     context
  #     |> ExecutionContext.append_message(
  #       Message.new_output(
  #         context.character_id,
  #         "{{error}}Unfortunately, your desired direction of travel is no longer possible.{{/error}}"
  #       )
  #     )
  #     |> ExecutionContext.set_success()
  #   end
  # end

  defp attempt_move_direction(direction, context, which) do
    result =
      Search.find_matches_in_area_v2(
        [:link],
        context.character.area_id,
        direction,
        which
      )

    case result do
      {:ok, [match]} ->
        attempt_move_link(context, match.match)

      {:ok, matches} ->
        handle_multiple_matches(context, matches)

      _error ->
        ExecutionContext.append_message(
          context,
          Message.new_output(
            context.character.id,
            "You cannot travel in that direction.",
            "error"
          )
        )
        |> ExecutionContext.set_success()
    end
  end

  defp handle_multiple_matches(context, matches) when length(matches) < 10 do
    descriptions = Enum.map(matches, & &1.short_description)

    error_msg = "{{warning}}Which exit?{{/warning}}"

    Util.multiple_match_error(context, descriptions, matches, error_msg, __MODULE__)
  end

  defp handle_multiple_matches(context, _matches) do
    error_msg = "Found too many exits. Please be more specific."

    ExecutionContext.append_message(
      context,
      Message.new_output(context.character.id, error_msg, "error")
    )
    |> ExecutionContext.set_success()
  end

  @doc """
  Given an ExecutionContext containing a Character, nothing else required, and a link, attempt to move a Character.
  """
  @spec attempt_move_link(Mud.Engine.Command.ExecutionContext.t(), Mud.Engine.Link.t()) ::
          Mud.Engine.Command.ExecutionContext.t()
  def attempt_move_link(context, link) do
    char = context.character

    if char.position == Character.standing() do
      move(context, link)
    else
      error_msg = "You must be standing before you can move."

      ExecutionContext.append_message(
        context,
        Message.new_output(context.character.id, error_msg, "error")
      )
      |> ExecutionContext.set_success()
    end
  end

  defp move(context, link) do
    # Move the character in the database
    {:ok, character} = Character.update(context.character, %{area_id: link.to_id})

    # List all the characters that need to be informed of a move
    characters_by_area =
      Character.list_others_active_in_areas(character.id, [link.to_id, link.from_id])
      # Group by location
      |> Enum.group_by(fn char ->
        char.area_id
      end)

    # Perform look logic for character
    context
    |> ExecutionContext.append_message(
      Message.new_output(
        context.character.id,
        Area.long_description(link.to_id, context.character)
      )
    )
    # Send messages to everyone in room that the character just left
    |> ExecutionContext.append_message(
      Message.new_output(
        characters_by_area[link.from_id] || [],
        "#{character.name} left the area heading #{link.departure_text}.",
        "info"
      )
    )
    # Send messages to everyone in room that the character is arriving in
    |> ExecutionContext.append_message(
      Message.new_output(
        characters_by_area[link.to_id] || [],
        "#{character.name} has entered the area from #{link.arrival_text}.",
        "info"
      )
    )
    |> ExecutionContext.append_event(
      characters_by_area[link.from_id],
      UpdateArea.new(:remove, character)
    )
    |> ExecutionContext.append_event(
      characters_by_area[link.to_id],
      UpdateArea.new(:add, character)
    )
    |> ExecutionContext.append_event(
      character.id,
      UpdateCharacter.new(character)
    )
    |> ExecutionContext.set_success()
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
