defmodule Mud.Engine.Command.Move do
  @moduledoc """
  The MOVE command moves a Character from one area to another. This is usually via a directional exit but can be other things such as doors, gates, bridges, etc...

  Syntax:
    - move < exit | direction >

  Aliases:
    - go
    - cardinal/ordinal directions
    - relative directions

  Examples:
    - move south
    - out
    - go bridge
    - move red door
    - move right
    - west
    - ne
  """
  alias Mud.Engine.Command.Context
  alias Mud.Engine.{Character, Area, Link, Item}
  alias Mud.Engine.Event.Client.{UpdateArea, UpdateCharacter}
  alias Mud.Engine.Search
  alias Mud.Engine.Util
  alias Mud.Engine.Message

  use Mud.Engine.Command.Callback

  require Logger

  @spec build_ast([Mud.Engine.Command.AstNode.t(), ...]) ::
          Mud.Engine.Command.AstNode.OneThing.t()
  def build_ast(ast_nodes) do
    Mud.Engine.Command.AstUtil.build_one_thing_ast(ast_nodes)
  end

  # @impl true
  # def continue(%Context{} = context) do
  #   attempt_move(context.input.match, context)
  # end

  @impl true
  def execute(%Context{} = context) do
    ast = context.command.ast

    cond do
      ast.command in ["go", "move"] and is_nil(ast.thing) ->
        Context.append_message(
          context,
          Message.new_story_output(
            context.character.id,
            Util.get_module_docs(__MODULE__),
            "help_docs"
          )
        )

      ast.command not in ["go", "move"] ->
        direction =
          ast.command
          |> normalize_direction()

        attempt_move_direction(direction, context, 0)

      true ->
        cond do
          Regex.match?(
            ~r/^[A-F\d]{8}-[A-F\d]{4}-4[A-F\d]{3}-[89AB][A-F\d]{3}-[A-F\d]{12}:[A-F\d]{8}-[A-F\d]{4}-4[A-F\d]{3}-[89AB][A-F\d]{3}-[A-F\d]{12}$/i,
            ast.thing.input
          ) ->
            [from, to] = String.split(ast.thing.input, ":")
            link = Link.get!(from, to)

            if link.from_id == context.character.area_id do
              attempt_move_link(context, link)
            else
              Util.dave_error(context)
            end

          Util.is_uuid4(ast.thing.input) ->
            link = Link.get!(ast.thing.input)

            if link.from_id == context.character.area_id do
              attempt_move_link(context, link)
            else
              Util.dave_error(context)
            end

          true ->
            attempt_move_direction(ast.thing.input, context, ast.thing.which)
        end
    end
  end

  defp attempt_move_direction(direction, context, which) do
    Logger.debug(inspect({direction, context, which}))

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
        Context.append_message(
          context,
          Message.new_story_output(
            context.character.id,
            "You cannot travel in that direction.",
            "system_warning"
          )
        )
    end
  end

  # defp handle_multiple_matches(context, matches) when length(matches) < 10 do
  #   descriptions = Enum.map(matches, & &1.short_description)

  #   error_msg = "{{warning}}Which exit?{{/warning}}"

  #   Util.multiple_match_error(context, descriptions, matches, error_msg, __MODULE__)
  # end

  defp handle_multiple_matches(context, _matches) do
    Context.append_message(
      context,
      Message.new_story_output(
        context.character.id,
        "Found too many exits. Please be more specific.",
        "system_warning"
      )
    )
  end

  @doc """
  Given an Context containing a Character, nothing else required, and a link, attempt to move a Character.
  """
  @spec attempt_move_link(Mud.Engine.Command.Context.t(), Mud.Engine.Link.t()) ::
          Mud.Engine.Command.Context.t()
  def attempt_move_link(context, link) do
    char = context.character

    if char.position == Character.standing() do
      move(context, link)
    else
      Context.append_message(
        context,
        Message.new_story_output(
          context.character.id,
          "You must be standing before you can move.",
          "system_warning"
        )
      )
    end
  end

  defp move(context, link) do
    # Move the character in the database
    {:ok, character} = Character.update(context.character, %{area_id: link.to_id})
    area = Area.get!(link.to_id)

    items_are_scenery =
      Item.list_in_area(area.id)
      |> Enum.group_by(fn area ->
        area.is_scenery
      end)

    IO.inspect(items_are_scenery, label: "items_are_scenery")

    scenery = items_are_scenery[true]
    items_in_area = items_are_scenery[false]

    # List all the characters that need to be informed of a move
    characters_by_area =
      Character.list_others_active_in_areas(character.id, [link.to_id, link.from_id])
      # Group by location
      |> Enum.group_by(fn char ->
        char.area_id
      end)

    # Grab minimum info necessary to display other characters in area. Do not expose 'private' character info like stats and settings
    others_in_new_area = characters_by_area[link.to_id] || []

    links = Link.list_obvious_exits_in_area(area.id)

    # Perform look logic for character
    context
    |> Context.append_message(Area.long_description_to_story_output(area, context.character))
    # Send messages to everyone in room that the character just left
    |> Context.append_message(
      Message.new_story_output(
        characters_by_area[link.from_id] || [],
        "#{character.name} left the area heading #{link.departure_text}.",
        "info"
      )
    )
    # Send messages to everyone in room that the character is arriving in
    |> Context.append_message(
      Message.new_story_output(
        characters_by_area[link.from_id] || [],
        "#{character.name} has entered the area from #{link.arrival_text}.",
        "info"
      )
    )
    |> Context.append_event(
      characters_by_area[link.from_id],
      UpdateArea.new(%{
        action: :remove,
        other_characters: [character]
      })
    )
    |> Context.append_event(
      characters_by_area[link.to_id],
      UpdateArea.new(%{
        action: :add,
        other_characters: [character]
      })
    )
    |> Context.append_event(
      character.id,
      UpdateCharacter.new(character)
    )
    |> Context.append_event(
      character.id,
      UpdateArea.new(%{
        action: :look,
        area: area,
        other_characters: others_in_new_area,
        on_ground: items_in_area || [],
        toi: scenery || [],
        exits: links || []
      })
    )

    # area
    # other characters
    # items on ground
    # denizens
    # scenery/TOI
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
