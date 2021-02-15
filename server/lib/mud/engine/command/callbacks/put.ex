defmodule Mud.Engine.Command.Put do
  @moduledoc """
  The PUT command allows you to put something in your hand somewhere such as the ground or a container.

  Syntax:
    - put {left|right|all|[<which>] <thing>} > [my] [<which>] <thing>

  Examples:
    - put backpack > ground (effectively same as drop)
    - put quiver > shelf
    - put 2 shirt > 3 drawer
    - put 2 diamond > my 5 gem pouch
    - put pouch > chest > bottom drawer
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Event.Client.{UpdateArea, UpdateInventory}
  alias Mud.Engine.Item
  alias Mud.Engine.Item.Location
  alias Mud.Engine.Character
  alias Mud.Engine.Command.CallbackUtil
  alias Mud.Engine.Command.Context
  alias Mud.Engine.Util
  alias Mud.Engine.Search
  alias Mud.Engine.Message
  alias Mud.Engine.Command.AstNode.ThingAndPlace, as: TAP
  alias Mud.Engine.Command.AstNode.{Place, Thing}

  require Logger

  @spec build_ast([Mud.Engine.Command.AstNode.t(), ...]) ::
          Mud.Engine.Command.AstNode.ThingAndPlace.t()
  def build_ast(ast_nodes) do
    Mud.Engine.Command.AstUtil.build_tap_ast(ast_nodes)
  end

  @impl true
  def execute(context) do
    Logger.debug("Executing Put command")
    Logger.debug(inspect(context.command))
    ast = context.command.ast

    if is_nil(ast.thing) or is_nil(ast.place) do
      Logger.debug("Put command entered without input. Returning error with command docs.")

      Context.append_message(
        context,
        Message.new_story_output(
          context.character.id,
          Util.get_module_docs(__MODULE__),
          "system_info"
        )
      )
    else
      # A UUID was passed in which means the put command is being attempted on a specific item.
      # This sort of command should only be triggered by the UI.
      if Util.is_uuid4(context.command.ast.thing.input) do
        Logger.debug("Put command provided with uuid: #{context.command.ast.thing.input}")

        put_item_in_place_by_uuid(context)
      else
        Logger.debug("Provided input was not a uuid: #{context.command.ast.thing.input}")

        # If there is input but that input is not a UUID, that means the player typed text in. Go searching for the item.
        find_thing_to_put(context)
      end
    end
  end

  defp put_item_in_place_by_uuid(context) do
    case Item.get(context.command.ast.thing.input) do
      {:ok, item} ->
        if item.location.held_in_hand and item.location.character.id == context.character.id do
          find_place_to_put_thing(context, List.first(Search.things_to_match(item)), [])
        else
          Util.dave_error_v2(context)
        end

      _ ->
        Util.dave_error_v2(context)
    end
  end

  defp find_place_to_put_thing(
         context = %Mud.Engine.Command.Context{},
         thing,
         other_thing_matches
       ) do
    Logger.debug("Finding place to put thing: #{inspect(context.command.ast)}")

    case context.command.ast do
      # The place where the thing being put is not *necessarily* on the character. Look around area first.
      %TAP{place: %Place{personal: false}} ->
        find_place_in_area_or_inventory_to_put_thing(context, thing, other_thing_matches)

      # This thing will be in a place, but that place might not be on the character
      %TAP{place: %Place{personal: true}} ->
        find_place_in_inventory_to_put_thing(context, thing, other_thing_matches)
    end
  end

  defp find_place_in_area_or_inventory_to_put_thing(context, thing, other_thing_matches) do
    # IO.inspect(context.command.ast.place, label: :find_place_in_area_or_inventory_to_put_thing)

    results =
      if is_nil(context.command.ast.place.path) do
        Search.find_matches_in_area(
          context.character.area_id,
          context.command.ast.place.input,
          context.character.settings.commands.search_mode
        )
      else
        Search.find_matches_relative_to_place_in_area(
          context.character.area_id,
          context.command.ast.place,
          context.command.ast.place.path,
          context.character.settings.commands.search_mode
        )
      end

    # IO.inspect(results, label: :find_place_in_area_or_inventory_to_put_thing)

    # if place has a path, extract it and look for a place relative to a path
    # otherwise just look for a place somewhere in the area to put the thing into
    # double check to see if path requires sequential parent to work due to stow/get, and if so implement something else to handle put

    case results do
      {:ok, matches} ->
        sorted_results = CallbackUtil.sort_matches(matches)

        handle_search_results(context, {:ok, sorted_results}, thing, other_thing_matches)

      _ ->
        find_place_in_inventory_to_put_thing(context, thing, other_thing_matches)
    end
  end

  defp find_place_in_inventory_to_put_thing(context, thing, other_thing_matches) do
    # IO.inspect(context.command.ast, label: :find_place_in_inventory_to_put_thing)

    results =
      if is_nil(context.command.ast.place.path) do
        Search.find_matches_in_inventory(
          context.character.id,
          context.command.ast.place.input,
          context.character.settings.commands.search_mode
        )
      else
        place = context.command.ast.place

        thing = %Thing{
          input: place.input,
          which: place.which,
          personal: place.personal,
          where: place.where
        }

        Search.find_matches_relative_to_place_in_inventory(
          context.character.id,
          thing,
          context.command.ast.place.path,
          context.character.settings.commands.search_mode,
          false
        )
      end

    case results do
      {:ok, matches} ->
        sorted_results = CallbackUtil.sort_matches(matches)

        # then just handle results as normal
        handle_search_results(context, {:ok, sorted_results}, thing, other_thing_matches)

      _ ->
        handle_search_results(context, results, thing, other_thing_matches)
    end
  end

  defp find_thing_to_put(context = %Mud.Engine.Command.Context{}) do
    results =
      Search.find_matches_in_held_items(
        context.character.id,
        context.command.ast.thing.input,
        context.character.settings.commands.search_mode
      )

    case results do
      {:ok, [match]} ->
        find_place_to_put_thing(context, match, [])

      {:ok, matches} ->
        case context.character.settings.commands.multiple_matches_mode do
          "silent" ->
            [match | other_thing_matches] = CallbackUtil.sort_matches(matches)

            find_place_to_put_thing(context, match, other_thing_matches)

          "full path" ->
            [match | other_thing_matches] = CallbackUtil.sort_matches(matches)

            find_place_to_put_thing(context, match, other_thing_matches)

          "choose" ->
            Context.append_message(
              context,
              Message.new_story_output(
                context.character.id,
                "Multiple items to put were found, please be more specific.",
                "system_alert"
              )
            )
        end

      _ ->
        Util.not_found_error(context)
    end
  end

  defp handle_search_results(context, results, thing, other_thing_matches) do
    case results do
      # found a single place to put the thing
      {:ok, [match]} ->
        put_item(context, thing, other_thing_matches, match, [])

      # Found multiple places to put the thing
      {:ok, all_matches = [match | matches]} ->
        case context.command.ast do
          # If which is greater than 0, then more than one match was anticipated.
          # Make sure provided selection is not more than the number of items that were found
          %TAP{place: %Place{which: which}}
          when is_integer(which) and which > 0 and which <= length(all_matches) ->
            put_item(context, thing, other_thing_matches, Enum.at(matches, which - 1), [])

          # If the user provided a number but it is greater than the number of items found,
          %TAP{place: %Place{which: which}} when which > 0 and which > length(all_matches) ->
            Util.not_found_error(context)

          _ ->
            case context.character.settings.commands.multiple_matches_mode do
              "silent" ->
                put_item(context, thing, other_thing_matches, match, [])

              "full path" ->
                put_item(context, thing, other_thing_matches, match, matches)

              "choose" ->
                Context.append_message(
                  context,
                  Message.new_story_output(
                    context.character.id,
                    "Multiple places to put things were found, please be more specific.",
                    "system_alert"
                  )
                )
            end
        end

      _ ->
        Util.not_found_error(context)
    end
  end

  defp put_item(
         context,
         thing = %Search.Match{},
         other_thing_matches,
         place,
         other_place_matches
       ) do
    original_item = thing.match
    destination = place.match

    # IO.inspect("original_item")
    # IO.inspect(original_item)
    # IO.inspect("destination")
    # IO.inspect(destination)

    relative_location = CallbackUtil.relative_location_from_item(destination)
    # IO.inspect("relative_location")
    # IO.inspect(relative_location)

    location =
      Location.update_relative_to_item!(original_item.location, destination.id, relative_location)

    # IO.inspect("location")
    # IO.inspect(location)

    item = Map.put(original_item, :location, location)
    # IO.inspect("item")
    # IO.inspect(item)

    destination_in_area = Item.in_area?(destination.id, context.character.area_id)
    # IO.inspect("destination_in_area")
    # IO.inspect(destination_in_area)

    # if item.location.held_in_hand and item.location.character_id == context.character.id do
    #   # NEED TO KNOW WHERE THE HELL TO PUT IT
    items_in_path = Item.list_full_path(destination)
    # IO.inspect(items_in_path, label: :items_in_path)

    others =
      Character.list_others_active_in_areas(
        context.character.id,
        context.character.area_id
      )

    other_msg =
      [context.character.id | others]
      |> Message.new_story_output()
      |> Message.append_text("#{context.character.name}", "character")
      |> Message.append_text(" put ", "base")

    # |> Message.append_text(original_item.description.short, Util.get_item_type(original_item))

    other_msg =
      Util.construct_nested_item_location_message_for_others(
        context.character,
        other_msg,
        item,
        items_in_path,
        destination_in_area,
        relative_location
      )
      |> Message.append_text(".", "base")

    self_msg =
      context.character.id
      |> Message.new_story_output()
      |> Message.append_text("You", "character")
      |> Message.append_text(" put ", "base")

    self_msg =
      Util.construct_nested_item_location_message_for_self(
        self_msg,
        item,
        relative_location,
        true
      )
      |> Message.append_text(".", "base")

    self_msg =
      if other_thing_matches != [] do
        other_items = Enum.map(other_thing_matches, & &1.match)

        Util.append_assumption_text(
          self_msg,
          original_item,
          other_items,
          context.character.settings.commands.multiple_matches_mode
        )
      else
        self_msg
      end

    self_msg =
      if other_place_matches != [] do
        other_items = Enum.map(other_place_matches, & &1.match)

        Util.append_assumption_text(
          self_msg,
          original_item,
          other_items,
          context.character.settings.commands.multiple_matches_mode
        )
      else
        self_msg
      end

    all_items_to_update = Item.list_all_recursive_children(item)

    # check to see whether the update needs to go to only inventory or the area too
    context =
      if destination_in_area do
        context =
          Context.append_event(
            context,
            context.character_id,
            UpdateInventory.new(:remove, all_items_to_update)
          )

        if item.location.on_ground do
          Context.append_event(
            context,
            [context.character_id | others],
            UpdateArea.new(%{action: :add, items: [item]})
          )
        else
          context
        end

      else
        Context.append_event(
          context,
          context.character_id,
          UpdateInventory.new(:update, item)
        )
      end

    context
    |> Context.append_message(other_msg)
    |> Context.append_message(self_msg)
  end
end
