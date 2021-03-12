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
      Search.find_exits_in_area(
        context.character.area_id,
        direction,
        context.character.settings.commands.search_mode
      )

    # IO.inspect(result, label: :attempt_move_direction)

    case result do
      {:ok, [match | matches]}
      when is_integer(which) and which > 0 and which <= length(matches) ->
        attempt_move_link(context, match, matches)

      {:ok, matches} when is_integer(which) and which > 0 and which > length(matches) ->
        Util.not_found_error(context)

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
  #   descriptions = Enum.map(matches, & &1.description.short)

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
  @spec attempt_move_link(Mud.Engine.Command.Context.t(), Mud.Engine.Link.t(), [
          Mud.Engine.Link.t()
        ]) ::
          Mud.Engine.Command.Context.t()
  def attempt_move_link(context, link, other_links \\ []) do
    char = context.character

    if char.position == Character.standing() do
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

  # defp maybe_move(context, link, other_matches) do
  #   if not link.flags.closable or (link.flags.closable and link.closable.open) do
  #     move(context, link, other_matches)
  #   else
  #     upcased_desc = Mud.Engine.Util.upcase_first(link.short_description)

  #     Context.append_message(
  #       context,
  #       Message.new_story_output(
  #         context.character.id,
  #         "#{upcased_desc} is closed.",
  #         "system_alert"
  #       )
  #     )
  #   end
  # end

  defp maybe_update_unexplored(context, area, old_area) do
    # Check to see if this is a room that is being visited by the character for the first time
    if not Area.has_been_explored?(area.id, context.character.id) do
      unexplored_areas = Area.list_unexplored_areas_linked_to_area(area.id, context.character.id)

      unexplored_area_ids = Enum.map(unexplored_areas, & &1.id)
      unexplored_links = Link.list_links_between_areas(area.id, unexplored_area_ids)

      Area.mark_as_explored(area.id, context.character.id)

      context =
        Context.append_event(
          context,
          context.character.id,
          UpdateExploredArea.new(%{
            action: :add,
            areas: unexplored_areas,
            links: unexplored_links,
            explored: [area.id]
          })
        )

      # Check to see if in a map for the first time and update that if so
      if old_area.map_id != area.map_id and
           not Engine.Map.has_been_explored?(area.map_id, context.character.id) do
        Engine.Map.mark_as_explored(area.map_id, context.character.id)

        new_map = Engine.Map.get!(area.map_id)

        Context.append_event(
          context,
          context.character.id,
          UpdateExploredMap.new(%{
            action: :add,
            maps: [new_map]
          })
        )
      else
        context
      end
      |> maybe_update_known_shops(area)
    else
      context
    end
  end

  defp maybe_update_known_shops(context, area) do
    case Shop.list_by_area_with_products(area.id) do
      [] ->
        context

      shops ->
        Shop.mark_as_known(shops, context.character.id)

        Context.append_event(
          context,
          context.character.id,
          UpdateShops.new(%{
            action: :add,
            shops: shops
          })
        )
    end
  end

  defp move(context, link, other_matches) do
    # Move the character in the database
    {:ok, character} = Character.update(context.character, %{area_id: link.to_id})

    old_area = Area.get!(link.from_id)
    area = Area.get!(link.to_id)

    # check if area has already been explored. If it has do nothing. If not insert a record to say there was a visit
    # and add an event to the front end to send the updated area
    context = maybe_update_unexplored(context, area, old_area)

    # If moving between maps, update client with new map information
    context =
      if old_area.map_id != area.map_id do
        Context.append_event(
          context,
          context.character.id,
          UpdateMap.new(Engine.Map.fetch_character_data(character.id, area.map_id))
        )
      else
        context
      end

    # Split out scenery and non scenery
    items_in_area =
      Item.list_in_area(area.id)
      |> Stream.filter(fn item ->
        item.flags.hidden != true
      end)

    # List all the characters that need to be informed of a move
    characters_by_area =
      Character.list_others_active_in_areas(character.id, [link.to_id, link.from_id])
      # Group by location
      |> Enum.group_by(fn char ->
        char.area_id
      end)

    # Grab minimum info necessary to display other characters in area. Do not expose 'private' character info like stats and settings
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
        Util.append_assumption_text(
          personal_departure_message,
          link,
          other_matches,
          context.character.settings.commands.multiple_matches_mode
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
    message =
      character.id
      |> Message.new_story_output()

    # IO.inspect(link, label: :link)

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

      (link.flags.closable and link.closable.open) or link.flags.object ->
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

      (link.flags.closable and link.closable.open) or link.flags.object ->
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

      (link.flags.closable and link.closable.open) or link.flags.object ->
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
      Util.append_assumption_text(
        Message.new_story_output(context.character.id),
        link,
        other_links,
        context.character.settings.commands.multiple_matches_mode
      )
    )
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
