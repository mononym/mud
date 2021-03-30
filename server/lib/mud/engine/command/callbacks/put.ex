defmodule Mud.Engine.Command.Put do
  @moduledoc """
  The PUT command allows you to put something in your hand somewhere such as the ground or a container.

  Syntax:
    - put [left|right|all|<which>] <thing> in|on [my] [<which>] <thing>

  Examples:
    - put backpack on ground (effectively same as drop)
    - put quiver on shelf
    - put 2 shirt in 3 drawer
    - put 2 diamond in my 5 gem pouch
    - put pouch in chest in bottom drawer
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Event.Client.{UpdateArea, UpdateInventory}
  alias Mud.Engine.Item
  alias Mud.Engine.ItemUtil
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
        # This should only be triggered by a UI action. Don't trust anything though and validate that the item is
        # actually on the character in question
        # if item.location.held_in_hand and item.location.character_id == context.character.id do
        #   find_place_to_put_thing(context, List.first(Search.things_to_match(item)), [])
        # else
        #   Util.dave_error_v2(context)
        # end

        handle_thing_search_results(context, {:ok, Search.things_to_match(item)})

      _ ->
        Util.dave_error_v2(context)
    end
  end

  # Handles the logistics around single matches, multiple matches, and allowing the selection of one of a number of
  # possible matches via the original command. For example, you could type 'put 2 rock on shelf' and it would put the
  # second item that matched 'rock' instead of the first one as would be normal.
  defp handle_thing_search_results(context, results) do
    case results do
      # There is only a single match and the player did not try and specify a specific item so just roll with that.
      {:ok, [match]} when context.command.ast.thing.which == 0 ->
        find_place_to_put_thing(context, match)

      # There are possibly multiple matches, but the player might also have specified a specific item
      {:ok, all_matches = [match | matches]} ->
        case context.command.ast do
          # If which is greater than 0, then more than one match was anticipated and the player entered a number.
          # Make sure provided selection is not more than the number of items that were found
          %TAP{thing: %Thing{which: which}}
          when is_integer(which) and which > 0 and which <= length(all_matches) ->
            find_place_to_put_thing(context, Enum.at(all_matches, which - 1))

          # If the user provided a number but it is greater than the number of items found,
          %TAP{thing: %Thing{which: which}} when which > 0 and which > length(all_matches) ->
            Util.not_found_error(context)

          # The user did not preselect an item and we're just dealing with multiple matches. Fall through to the
          # normal find_place_to_put_thing function.
          _ ->
            # Determine what to do based on character preferences when it comes to multiple potential matches.
            case context.character.settings.commands.multiple_matches_mode do
              "silent" ->
                # If their choice is "silent" that means just drop the extras so it is like they don't exist
                find_place_to_put_thing(context, match, [])

              key when key in ["item only", "full path"] ->
                # If their choice is "full path" or "item only" that means pass everything through for generating messages later
                find_place_to_put_thing(context, match, matches)

              "choose" ->
                Context.append_message(
                  context,
                  Message.new_story_output(
                    context.character.id,
                    "Multiple items were found, please be more specific.",
                    "system_alert"
                  )
                )
            end
        end

      # No results were found so return a standard error.
      _ ->
        Util.not_found_error(context)
    end
  end

  # Have a thing to put but need a place to put it
  defp find_place_to_put_thing(
         context = %Mud.Engine.Command.Context{},
         thing,
         other_thing_matches \\ []
       ) do
    Logger.debug("Finding place to put thing: #{inspect(context.command.ast)}")

    case context.command.ast do
      # The place where the thing being put is not *necessarily* on the character. Look around area first.
      %TAP{place: %Place{personal: false}} ->
        find_place_in_area_or_inventory_to_put_thing(context, thing, other_thing_matches)

      # This thing will be in a place that is somewhere in the character's inventory
      %TAP{place: %Place{personal: true}} ->
        find_place_in_inventory_to_put_thing(context, thing, other_thing_matches)
    end
  end

  defp find_place_in_area_or_inventory_to_put_thing(context, thing, other_thing_matches) do
    # There is no extended path, ie: in backpack in sack on shelf
    # So just try to find a thing in the area that can be seen to try and place the item on
    results =
      if is_nil(context.command.ast.place.path) do
        Search.find_matches_in_area(
          context.character.area_id,
          context.command.ast.place.input,
          context.character.settings.commands.search_mode
        )
      else
        # There is an extended path, ie: in backpack in sack on shelf
        Search.find_matches_relative_to_place_in_area(
          context.character.area_id,
          context.command.ast.place,
          context.command.ast.place.path,
          context.character.settings.commands.search_mode
        )
      end

    # if place has a path, extract it and look for a place relative to a path
    # otherwise just look for a place somewhere in the area to put the thing into
    # double check to see if path requires sequential parent to work due to stow/get, and if so implement something else to handle put

    case results do
      {:ok, matches} ->
        sorted_results = CallbackUtil.sort_matches(matches, false)

        handle_search_results(context, {:ok, sorted_results}, thing, other_thing_matches)

      _ ->
        find_place_in_inventory_to_put_thing(context, thing, other_thing_matches)
    end
  end

  defp find_place_in_inventory_to_put_thing(context, thing, other_thing_matches) do
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
        sorted_results = CallbackUtil.sort_matches(matches, false)

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
      {:ok, matches} ->
        sorted_results = CallbackUtil.sort_matches(matches, true)

        handle_thing_search_results(context, {:ok, sorted_results})

      _ ->
        Util.not_found_error(context)
    end
  end

  defp handle_search_results(context, results, thing, other_thing_matches) do
    case results do
      # found a single place to put the thing
      {:ok, [match]} ->
        validate_thing_and_place_for_put(context, thing, other_thing_matches, match, [])

      # Found multiple places to put the thing
      {:ok, all_matches = [match | matches]} ->
        case context.command.ast do
          # If which is greater than 0, then more than one match was anticipated.
          # Make sure provided selection is not more than the number of items that were found
          %TAP{place: %Place{which: which}}
          when is_integer(which) and which > 0 and which <= length(all_matches) ->
            validate_thing_and_place_for_put(
              context,
              thing,
              other_thing_matches,
              Enum.at(all_matches, which - 1),
              []
            )

          # If the user provided a number but it is greater than the number of items found,
          %TAP{place: %Place{which: which}} when which > 0 and which > length(all_matches) ->
            Util.not_found_error(context)

          _ ->
            case context.character.settings.commands.multiple_matches_mode do
              "silent" ->
                validate_thing_and_place_for_put(context, thing, other_thing_matches, match, [])

              "full path" ->
                validate_thing_and_place_for_put(
                  context,
                  thing,
                  other_thing_matches,
                  match,
                  matches
                )

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

  defp validate_thing_and_place_for_put(
         context,
         thing = %Search.Match{},
         other_thing_matches,
         place,
         other_place_matches
       ) do
    # If things aren't right will need to generate error message here
    cond do
      # Either the item being put somewhere is not in the hand, or the character the item is held by is not
      # the character executing the command, or the place the item is being put is not in the proper area.
      # Either way this should never happen.
      not thing.match.location.held_in_hand or
          (thing.match.location.held_in_hand and
             thing.match.location.character_id != context.character.id) ->
        Util.dave_error_v2(context)

      # Trying to put an item in or on a place where that relationship is not viable
      (context.command.ast.thing.where == "in" and not place.match.flags.has_pocket) or
          (context.command.ast.thing.where == "on" and not place.match.flags.has_surface) ->
        Context.append_message(
          context,
          Message.new_story_output(
            context.character.id,
            "You cannot put anything `#{context.command.ast.thing.where}` ",
            "system_warning"
          )
          |> Message.append_text(
            place.match.description.short,
            Mud.Engine.Util.get_item_type(place.match)
          )
          |> Message.append_text(".", "system_warning")
        )

      # TODO Implement size/weight/count checks
      # item has to fit dimentionally
      # item has to fit by weight
      # item has to fit by count
      true ->
        fits_results =
          if context.command.ast.thing.where == "in" do
            ItemUtil.items_fit_in_pocket(thing.match, place.match)
          else
            ItemUtil.items_fit_on_surface(thing.match, place.match)
          end

        case fits_results do
          true ->
            execute_put_item(
              context,
              thing,
              other_thing_matches,
              place,
              other_place_matches
            )

          {:error, :dimensions} ->
            self_msg =
              context.character.id
              |> Message.new_story_output()
              |> Message.append_text(
                Util.upcase_first(thing.match.description.short),
                Mud.Engine.Util.get_item_type(thing.match)
              )
              |> Message.append_text(
                " is too big to fit {#context.command.ast.thing.where} ",
                "system_warning"
              )
              |> Message.append_text(
                place.match.description.short,
                Mud.Engine.Util.get_item_type(place.match)
              )
              |> Message.append_text(".", "system_warning")

            Context.append_message(context, self_msg)

          {:error, :weight} ->
            self_msg =
              context.character.id
              |> Message.new_story_output()
              |> Message.append_text(
                Util.upcase_first(place.match.description.short),
                Mud.Engine.Util.get_item_type(place.match)
              )
              |> Message.append_text(
                " cannot hold the additional weight of ",
                "system_warning"
              )
              |> Message.append_text(
                thing.match.description.short,
                Mud.Engine.Util.get_item_type(thing.match)
              )
              |> Message.append_text(".", "system_warning")

            Context.append_message(context, self_msg)

          {:error, :count} ->
            self_msg =
              context.character.id
              |> Message.new_story_output()
              |> Message.append_text(
                "There are already too many items {#context.command.ast.thing.where} ",
                "system_warning"
              )
              |> Message.append_text(
                place.match.description.short,
                Mud.Engine.Util.get_item_type(place.match)
              )
              |> Message.append_text(".", "system_warning")

            Context.append_message(context, self_msg)
        end
    end
  end

  defp execute_put_item(
         context,
         thing = %Search.Match{},
         other_thing_matches,
         place,
         other_place_matches
       ) do
    original_item = thing.match
    destination = place.match

    relative_location = CallbackUtil.relative_location_from_item(destination)

    location =
      Location.update_relative_to_item!(original_item.location, destination.id, relative_location)

    item = Map.put(original_item, :location, location)

    destination_in_area = Item.in_area?(destination.id, context.character.area_id)

    items_in_path = Item.list_full_path(destination)

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

    other_msg =
      CallbackUtil.construct_item_current_location_movement_message_for_others(
        context.character,
        other_msg,
        item,
        items_in_path,
        destination_in_area
      )
      |> Message.append_text(".", "base")

    self_msg =
      context.character.id
      |> Message.new_story_output()
      |> Message.append_text("You", "character")
      |> Message.append_text(" put ", "base")

    self_msg =
      CallbackUtil.construct_item_current_location_message(
        self_msg,
        item,
        context.character
      )
      |> Message.append_text(".", "base")

    self_msg =
      if other_thing_matches != [] do
        other_items = Enum.map(other_thing_matches, & &1.match)

        CallbackUtil.append_assumption_text(
          self_msg,
          original_item,
          other_items,
          context.character.settings.commands.multiple_matches_mode,
          context.character
        )
      else
        self_msg
      end

    self_msg =
      if other_place_matches != [] do
        other_places = Enum.map(other_place_matches, & &1.match)

        CallbackUtil.append_assumption_text(
          self_msg,
          place.match,
          other_places,
          context.character.settings.commands.multiple_matches_mode,
          context.character
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
