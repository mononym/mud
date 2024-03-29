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
  alias Mud.Engine
  alias Mud.Engine.Command.Context
  alias Mud.Engine.{Character, Area, Link, Item, Shop}

  alias Mud.Engine.Event.Client.{
    UpdateArea,
    UpdateMap,
    UpdateCharacter,
    UpdateExploredArea,
    UpdateExploredMap,
    UpdateShops
  }

  alias Mud.Engine.Search
  alias Mud.Engine.Util
  alias Mud.Engine.Message
  alias Mud.Engine.Link.Closable
  alias Mud.Engine.Command.CallbackUtil

  use Mud.Engine.Command.Callback

  require Logger

  @spec build_ast([Mud.Engine.Command.AstNode.t(), ...]) ::
          Mud.Engine.Command.AstNode.OneThing.t()
  def build_ast(ast_nodes) do
    Mud.Engine.Command.AstUtil.build_one_thing_ast(ast_nodes)
  end

  # @impl true
  # def continue(%Context{} = context) do
  #   attempt_maybe_move(context.input.match, context)
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
        attempt_move_direction(ast.command, context, 0)

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

    normalized_direction = normalize_direction(direction)

    result =
      Search.find_exits_in_area(
        context.character.area_id,
        normalized_direction,
        context.character.settings.commands.search_mode
      )

    case result do
      {:ok, [match | matches]}
      when is_integer(which) and which > 0 and which <= length(matches) ->
        attempt_move_link(context, match, matches)

      {:ok, matches} when is_integer(which) and which > 0 and which > length(matches) ->
        Util.not_found_error(context)

      {:ok, [match]}
      when normalized_direction != "out" or
             (normalized_direction == "out" and match.short_description == "out") ->
        attempt_move_link(context, match.match)

      {:ok, matches} when normalized_direction != "out" ->
        match_fun = fn match ->
          match.match.short_description == normalized_direction
        end

        matches =
          if Enum.any?(matches, match_fun) do
            Enum.filter(matches, match_fun)
          else
            matches
          end

        if length(matches) == 1 do
          [match] = matches
          attempt_move_link(context, match.match)
        else
          handle_multiple_matches(context, matches)
        end

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
  @spec attempt_move_link(Mud.Engine.Command.Context.t(), Mud.Engine.Link.t(), [
          Mud.Engine.Link.t()
        ]) ::
          Mud.Engine.Command.Context.t()
  def attempt_move_link(context, link, other_links \\ []) do
    char = context.character

    if char.status.position == Character.standing() do
      # maybe_move(context, link, other_links)
      move(context, link, other_links)
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

  defp move(context, link, other_matches) do
    # Move the character in the database
    {:ok, character} = Character.update(context.character, %{area_id: link.to_id})

    old_area = Area.get!(link.from_id)
    area = Area.get!(link.to_id)

    area_has_been_explored = Area.has_been_explored?(area.id, context.character.id)

    context =
      cond do
        not area_has_been_explored and
            old_area.map_id !=
              area.map_id ->
          Area.mark_as_explored(area.id, context.character.id)

          new_update =
            UpdateMap.new(
              Map.merge(
                %{map_id: area.map_id, area_id: area.id},
                Engine.Map.fetch_character_data(character.id, area.map_id)
              )
            )

          if not Engine.Map.has_been_explored?(area.map_id, context.character.id) do
            Engine.Map.mark_as_explored(area.map_id, context.character.id)
            new_map = Engine.Map.get!(area.map_id)

            event = %{
              new_update
              | maps: [new_map | new_update.maps]
            }

            Context.append_event(
              context,
              context.character.id,
              event
            )
          else
            Context.append_event(
              context,
              context.character.id,
              new_update
            )
          end

        not area_has_been_explored and
            old_area.map_id ==
              area.map_id ->
          Area.mark_as_explored(area.id, context.character.id)

          unexplored_areas =
            Area.list_unexplored_areas_linked_to_area(area.id, context.character.id)

          unexplored_area_ids = Enum.map(unexplored_areas, & &1.id)
          unexplored_links = Link.list_links_between_areas(area.id, unexplored_area_ids)

          Context.append_event(
            context,
            context.character.id,
            UpdateMap.new(%{
              map_id: area.map_id,
              area_id: area.id,
              areas: [area | unexplored_areas],
              links: unexplored_links,
              explored_areas: [area.id]
            })
          )

        area_has_been_explored and
            old_area.map_id !=
              area.map_id ->
          Context.append_event(
            context,
            context.character.id,
            UpdateMap.new(
              Map.merge(
                %{map_id: area.map_id, area_id: area.id},
                Engine.Map.fetch_character_data(character.id, area.map_id)
              )
            )
          )

        area_has_been_explored and
            old_area.map_id ==
              area.map_id ->
          Context.append_event(
            context,
            context.character.id,
            UpdateMap.new(%{map_id: area.map_id, area_id: area.id})
          )
      end

    # Grab all items and visible nested items
    items_in_area = Item.list_items_in_area_and_nested_visible_items(area.id)

    # List all the characters that need to be informed of a move
    characters_by_area =
      Character.list_others_active_in_areas(character.id, [link.to_id, link.from_id])
      # Group by location
      |> Enum.group_by(fn char ->
        char.area_id
      end)

    # Grab minimum info necessary to display other characters in area. TODO: Do not expose 'private' character info like stats and settings
    others_in_new_area = characters_by_area[link.to_id] || []
    others_in_old_area = characters_by_area[link.from_id] || []

    # If the link was a closable one and was closed, open it and also add an update for everyone for the front end
    context = maybe_open_link(context, link, others_in_new_area)

    links = Link.list_obvious_exits_in_area(area.id)

    # If there were other possible exits, call out that there were *before* any other messaging to the front end
    context = maybe_add_assumption_message(context, link, other_matches)

    personal_departure_message = construct_personal_departure_message(character, link)

    personal_departure_message =
      if length(other_matches) > 0 do
        CallbackUtil.append_assumption_text(
          personal_departure_message,
          link,
          other_matches,
          context.character.settings.commands.multiple_matches_mode,
          context.character
        )
      else
        personal_departure_message
      end

    # Perform look logic for character
    context
    |> Context.append_message(personal_departure_message)
    |> Context.append_message(Area.long_description_to_story_output(area, context.character))
    # Send messages to everyone in room that the character just left
    |> Context.append_message(construct_departure_message(character, link, others_in_old_area))
    # Send messages to everyone in room that the character is arriving in
    |> Context.append_message(construct_arrival_message(character, link, others_in_new_area))
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
      UpdateArea.new(%{
        action: :look,
        area: area,
        other_characters: others_in_new_area,
        items: items_in_area,
        exits: links
      })
    )
    |> Context.append_event(
      character.id,
      UpdateCharacter.new("character", character)
    )
  end

  defp maybe_open_link(context, link, others) do
    if link.flags.closable and not link.closable.open do
      # save thing as open
      closable = Closable.update!(link.closable, %{open: true})
      link = %{link | closable: closable}

      context = CallbackUtil.maybe_open_opposite_link(context, link)

      # Inform everyone the thing has been opened
      Context.append_event(
        context,
        [context.character_id | others],
        UpdateArea.new(%{action: :update, exits: [link]})
      )
    else
      context
    end
  end

  defp construct_personal_departure_message(character, link) do
    Logger.debug("Constructing departure message for link: #{inspect(link)}")

    message =
      character.id
      |> Message.new_story_output()

    cond do
      # Heading through the closed thing, so craft message about it being opened as character goes through
      link.flags.closable and not link.closable.open ->
        message
        |> Message.append_text("You ", "character")
        |> Message.append_text("open and head #{link.departure_text} ", "base")
        |> Message.append_text(
          link.short_description,
          Mud.Engine.Util.get_link_type(link)
        )
        |> Message.append_text(".", "base")

      (link.flags.closable and link.closable.open) or link.flags.object or link.flags.portal ->
        message
        |> Message.append_text("You ", "character")
        |> Message.append_text("head #{link.departure_text} ", "base")
        |> Message.append_text(
          link.short_description,
          Mud.Engine.Util.get_link_type(link)
        )
        |> Message.append_text(".", "base")

      # Everything else is assumed to be a direction or open.
      link.flags.direction ->
        message
        |> Message.append_text("You ", "character")
        |> Message.append_text("head ", "base")
        |> Message.append_text(
          link.short_description,
          Mud.Engine.Util.get_link_type(link)
        )
        |> Message.append_text(".", "base")
    end
  end

  defp construct_departure_message(character, link, others) do
    message =
      others
      |> Message.new_story_output()

    cond do
      # Heading through the closed thing, so craft message about it being opened as character goes through
      link.flags.closable and not link.closable.open ->
        message
        |> Message.append_text(character.name, "character")
        |> Message.append_text(" opened and went #{link.departure_text} ", "base")
        |> Message.append_text(
          link.short_description,
          Mud.Engine.Util.get_link_type(link)
        )
        |> Message.append_text(".", "base")

      (link.flags.closable and link.closable.open) or link.flags.object or link.flags.portal ->
        message
        |> Message.append_text(character.name, "character")
        |> Message.append_text(" went #{link.departure_text} ", "base")
        |> Message.append_text(
          link.short_description,
          Mud.Engine.Util.get_link_type(link)
        )
        |> Message.append_text(".", "base")

      # Everything else is assumed to be a direction or open.
      link.flags.direction ->
        message
        |> Message.append_text(character.name, "character")
        |> Message.append_text(" went ", "base")
        |> Message.append_text(
          link.short_description,
          Mud.Engine.Util.get_link_type(link)
        )
        |> Message.append_text(".", "base")
    end
  end

  defp construct_arrival_message(character, link, others) do
    message = others |> Message.new_story_output()

    cond do
      # Heading through the closed thing, so craft message about it being opened as character goes through
      link.flags.closable and not link.closable.open ->
        message
        |> Message.append_text(character.name, "character")
        |> Message.append_text(" arrived #{link.arrival_text} ", "base")
        |> Message.append_text(
          link.short_description,
          Mud.Engine.Util.get_link_type(link)
        )
        |> Message.append_text(" which just opened.", "base")

      (link.flags.closable and link.closable.open) or link.flags.object or link.flags.portal ->
        message
        |> Message.append_text(character.name, "character")
        |> Message.append_text(" arrived #{link.arrival_text} ", "base")
        |> Message.append_text(
          link.short_description,
          Mud.Engine.Util.get_link_type(link)
        )
        |> Message.append_text(".", "base")

      # Everything else is assumed to be a direction or open.
      link.flags.direction ->
        message
        |> Message.append_text(character.name, "character")
        |> Message.append_text(" arrived from the ", "base")
        |> Message.append_text(
          link.arrival_text,
          Mud.Engine.Util.get_link_type(link)
        )
        |> Message.append_text(".", "base")
    end
  end

  defp maybe_add_assumption_message(context, _, []) do
    context
  end

  defp maybe_add_assumption_message(context, link, other_links) do
    Context.append_message(
      context,
      CallbackUtil.append_assumption_text(
        Message.new_story_output(context.character.id),
        link,
        other_links,
        context.character.settings.commands.multiple_matches_mode,
        context.character
      )
    )
  end

  defp normalize_direction(direction) do
    cond do
      direction in ["nw", "northw", "northwe", "northwes"] -> "northwest"
      direction in ["ne", "northe", "northea", "northeas"] -> "northeast"
      direction in ["n", "no", "nor", "nort"] -> "north"
      direction in ["s", "so", "sou", "sout"] -> "south"
      direction in ["e", "ea", "eas"] -> "east"
      direction in ["w", "we", "wes"] -> "west"
      direction in ["sw", "southw", "southwe", "southwes"] -> "southwest"
      direction in ["se", "southe", "southea", "southeas"] -> "southeast"
      direction in ["i"] -> "in"
      direction in ["o", "ou"] -> "out"
      direction in ["u"] -> "up"
      direction in ["d", "do", "dow"] -> "down"
      true -> direction
    end
  end
end
