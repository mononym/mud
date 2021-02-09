defmodule Mud.Engine.Command.Stow do
  @moduledoc """
  The STOW command takes one or more items and places them in your inventory.

  Where an item ends up in your inventory depends on configuration which can be changed with the STORE command. See HELP STORE for further information.

  By default, the largest container on a character is treated as their "default" or "primary" container and all items, other than gems, will be placed there.

  Gems are a special case where, unless otherwise specified, a gem pouch worn on the character will be searched out first and only if that is not found will the default container be fallen back on. If an explicit container is set using STORE this behavior is overridden and a gem pouch is not searched for.

  Setting a container for a type of item, such as armor, will cause the STOW command to search for that container on the character first and only if it is not found will the default container be fallen back on.

  STOW ignores the open/closed status of a container, allowing you to insert items into a closed container without having to open it while leaving said container closed at the end of the interaction.

  STOW will not be able to find a configured container if it is removed from your inventory, however if you do not alter the configuration and the container ends back up in your inventory STOW will be able to find it again.

  When specifying the place of a specific item to stow `from` is used, such as `stow sword from stone`.

  To set the default container for a specific item, add `in <container>` to the end of the command. For example, `store sword from stone in backpack`.

  Options:
    - LEFT: STOW an item from your left hand.
    - RIGHT: STOW an item from your right hand.
    - BOTH: STOW any items from your hands.

  Syntax:
    - STOW {LEFT | RIGHT | BOTH |[my] [<number>] <object>} [from [my] [<number>] <place>] [in]

  Examples:
    - stow topaz in lootsack
    - stow rock
    - stow both
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Event.Client.{UpdateArea, UpdateInventory, UpdateCharacter}
  alias Mud.Engine.Item
  alias Mud.Engine.Character
  alias Mud.Engine.Command.Context
  alias Mud.Engine.Util
  alias Mud.Engine.Search
  alias Mud.Engine.Message
  alias Mud.Engine.Item.Location
  alias Mud.Engine.Command.AstNode.{Place, Thing}
  alias Mud.Engine.Command.AstNode.ThingAndPlace, as: TAP
  alias Mud.Engine.Command.CallbackUtil

  require Logger

  @spec build_ast([Mud.Engine.Command.AstNode.t(), ...]) ::
          Mud.Engine.Command.AstNode.ThingAndPlace.t()
  def build_ast(ast_nodes) do
    Mud.Engine.Command.AstUtil.build_tap_ast(ast_nodes)
  end

  @impl true
  def execute(context) do
    Logger.debug("Executing Stow command")
    Logger.debug(inspect(context))
    ast = context.command.ast

    if is_nil(ast.thing) do
      Logger.debug("Stow command entered without input. Returning command docs.")

      Context.append_message(
        context,
        Message.new_story_output(
          context.character.id,
          Util.get_module_docs(__MODULE__),
          "system_info"
        )
      )
    else
      # A UUID was passed in which means the stow command is being attempted on a specific item.
      # This sort of command should only be triggered by the UI.
      if Util.is_uuid4(context.command.ast.thing.input) do
        Logger.debug("Stow command provided with uuid: #{context.command.ast.thing.input}")

        stow_item_by_uuid(context)
      else
        Logger.debug("Provided input was not a uuid: #{context.command.ast.thing.input}")

        # If there is input but that input is not a UUID, that means the player typed text in. Go searching for the item.
        find_thing_to_stow(context)
      end
    end
  end

  defp stow_item_by_uuid(context) do
    Logger.debug("stow_item_by_uuid")

    case Item.get(context.command.ast.thing.input) do
      {:ok, item} ->
        Logger.debug("found item by uuid")
        stow_item(context, List.first(Search.things_to_match(item)))

      _ ->
        Logger.debug("did not find item by uuid")
        Util.dave_error_v2(context)
    end
  end

  defp stow_thing_in_left_hand(context) do
    case Item.get_item_in_hand_as_list(context.character.id, "left") do
      [] ->
        handle_search_results(context, {:error, :not_found})

      item ->
        handle_search_results(context, {:ok, Search.things_to_match(item)})
    end
  end

  defp stow_thing_in_right_hand(context) do
    case Item.get_item_in_hand_as_list(context.character.id, "right") do
      [] ->
        handle_search_results(context, {:error, :not_found})

      item ->
        handle_search_results(context, {:ok, Search.things_to_match(item)})
    end
  end

  defp find_thing_to_stow(context = %Mud.Engine.Command.Context{}) do
    Logger.debug("find_thing_to_stow")
    Logger.debug(context.command.ast)

    case context.command.ast do
      # If my was specific with no place, stow something from hands
      %TAP{place: nil, thing: %Thing{personal: true}} ->
        Logger.debug("Item to Stow should be in character hands")

        stow_item_in_hands(context)

      # Thing being stowed did not have 'my' specified, but also no place either
      %TAP{place: nil, thing: %Thing{personal: false, input: "left"}} ->
        stow_thing_in_left_hand(context)

      # Thing being stowed did not have 'my' specified, but also no place either
      %TAP{place: nil, thing: %Thing{personal: false, input: "right"}} ->
        stow_thing_in_right_hand(context)

      # Thing being stowed did not have 'my' specified, but also no place either
      %TAP{place: nil, thing: %Thing{personal: false, input: "both"}} ->
        if context.character.handedness == "right" do
          context
          |> stow_thing_in_right_hand()
          |> stow_thing_in_left_hand()
        else
          context
          |> stow_thing_in_left_hand()
          |> stow_thing_in_right_hand()
        end

      # Thing being stowed did not have 'my' specified, but also no place either
      %TAP{place: nil, thing: %Thing{personal: false}} ->
        Logger.debug("in area or hands")
        stow_thing_in_area_or_hands(context)

      # This thing will be in a place, but that place might not be on the character
      %TAP{place: %Place{personal: false}, thing: %Thing{personal: false}} ->
        Logger.debug("in place in area or hands")
        stow_item_with_place(context)

      # stow thing in container on character
      %TAP{place: %Place{personal: place}, thing: %Thing{personal: thing}} when place or thing ->
        Logger.debug("in place in hands")
        stow_item_with_personal_place(context)
    end
  end

  defp stow_item_in_hands(context) do
    Logger.debug("stow_item_in_hands")

    results =
      Search.find_matches_in_held_items(
        context.character.id,
        context.command.ast.thing.input,
        context.character.settings.commands.search_mode
      )

    case results do
      {:ok, matches} ->
        sorted_results = CallbackUtil.sort_matches(matches)

        handle_search_results(context, {:ok, sorted_results})

      _ ->
        handle_search_results(context, results)
    end
  end

  defp handle_search_results(context, results) do
    Logger.debug("handle_search_results")
    Logger.debug(inspect(results))

    case results do
      {:ok, [match]} ->
        stow_item(context, match)

      {:ok, all_matches = [match | matches]} ->
        case context.command.ast do
          # If which is greater than 0, then more than one match was anticipated.
          # Make sure provided selection is not more than the number of items that were found
          %TAP{thing: %Thing{which: which}}
          when is_integer(which) and which > 0 and which <= length(all_matches) ->
            stow_item(context, Enum.at(matches, which - 1))

          # If the user provided a number but it is greater than the number of items found,
          %TAP{thing: %Thing{which: which}} when which > 0 and which > length(all_matches) ->
            Util.not_found_error(context)

          _ ->
            case context.character.settings.commands.multiple_matches_mode do
              "silent" ->
                stow_item(context, match, [])

              "alert" ->
                stow_item(context, match, matches)

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

      _ ->
        Util.not_found_error(context)
    end
  end

  defp stow_item_with_place(context) do
    Logger.debug("stow_item_with_place")
    # look for place on ground on in hands or worn
    area_results =
      Search.find_matches_relative_to_place_in_area(
        context.character.area_id,
        context.command.ast.thing,
        context.command.ast.place,
        context.character.settings.commands.search_mode
      )

    case area_results do
      {:ok, area_matches} when area_matches != [] ->
        handle_search_results(context, {:ok, CallbackUtil.sort_matches(area_matches)})

      _ ->
        stow_item_with_personal_place(context)
    end
  end

  defp stow_item_with_personal_place(context) do
    Logger.debug("stow_item_with_personal_place")
    # look for place on ground on in hands or worn
    results =
      Search.find_matches_relative_to_place_in_hands(
        context.character.id,
        context.command.ast.thing,
        context.command.ast.place,
        context.character.settings.commands.search_mode
      )

    handle_search_results(context, results)
  end

  defp stow_thing_in_area_or_hands(context) do
    Logger.debug("stow_thing_in_area_or_hands")

    area_results =
      Search.find_matches_in_area(
        context.character.area_id,
        context.command.ast.thing.input,
        context.character.settings.commands.search_mode
      )

    case area_results do
      {:ok, area_matches} when area_matches != [] ->
        handle_search_results(context, {:ok, CallbackUtil.sort_matches(area_matches)})

      _ ->
        stow_item_in_hands(context)
    end
  end

  defp stow_item(context, thing = %Search.Match{}, other_matches \\ []) do
    Logger.debug("stow_item")
    Logger.debug(thing.match)
    in_area = Item.in_area?(thing.match.id, context.character.area_id)
    in_hands = thing.match.location.held_in_hand
    parent_containers_open = Item.parent_containers_open?(thing.match)
    original_item = thing.match

    cond do
      parent_containers_open and (in_area or in_hands) ->
        if original_item.flags.coin do
          # update character wealth
          wealth_attrs =
            CallbackUtil.coin_to_wealth_update_attrs(
              original_item.coin,
              context.character.wealth
            )

          updated_wealth =
            Mud.Engine.Character.Wealth.update!(context.character.wealth, wealth_attrs)

          character = Map.put(context.character, :wealth, updated_wealth)

          # Delete coins since they don't really exist and don't need to be moved
          Item.delete(original_item)

          others =
            Character.list_others_active_in_areas(
              context.character.id,
              context.character.area_id
            )

          other_msg =
            others
            |> Message.new_story_output()
            |> Message.append_text("[#{context.character.name}]", "character")
            |> Message.append_text(" picks up ", "base")
            |> Message.append_text(
              CallbackUtil.coin_to_count_string(original_item.coin),
              Mud.Engine.Util.get_item_type(original_item)
            )
            |> Message.append_text(".", "base")

          self_msg =
            context.character.id
            |> Message.new_story_output()
            |> Message.append_text("You", "character")
            |> Message.append_text(" pick up ", "base")
            |> Message.append_text(
              CallbackUtil.coin_to_count_string(original_item.coin),
              Mud.Engine.Util.get_item_type(original_item)
            )
            |> Message.append_text(".", "base")

          context
          |> Context.append_event(
            character.id,
            UpdateCharacter.new(%{action: "wealth", wealth: updated_wealth})
          )
          |> Context.append_event(
            [context.character_id | others],
            UpdateArea.new(%{action: :remove, on_ground: [original_item]})
          )
          |> Context.append_message(other_msg)
          |> Context.append_message(self_msg)
        else
          # have item that needs to be stowed.
          # check the type of item and get the container that it should go into
          # make sure container it should go into is still somewhere in inventory, even if that means somewhere held in the hands
          # if container is somewhere in inventory that is good enough
          # if container is not in inventory fallback to default container and repeat check
          # if default container is not in inventory, get all worn containers and grab the largest one
          # if there are no worn containers, flip the fuck out, orhterwise return the container that the item should be put into (for later checks on capacity etc...)
          case get_stow_target_container(context.character.containers, thing.match) do
            container when is_struct(container) ->
              # have an item to stow
              # have a container to stow the item into
              # change item location
              # create messaging
              location = Location.update_relative_to_item!(thing.match.location, container.id)
              items_in_path = Item.list_full_path(container)
              IO.inspect(items_in_path, label: :items_in_path)

              IO.inspect("updated location")
              IO.inspect(location)
              IO.inspect(container)

              item = Map.put(thing.match, :location, location)
              IO.inspect("item")
              IO.inspect(item)

              others =
                Character.list_others_active_in_areas(
                  context.character.id,
                  context.character.area_id
                )

              IO.inspect("got others")

              other_msg =
                [context.character.id | others]
                |> Message.new_story_output()
                |> Message.append_text("#{context.character.name}", "character")
                |> Message.append_text(" stows ", "base")

              # TODO: Figure out only displaying the outermost container for the item, or the item itself it is the outermost container
              other_msg =
                Util.construct_nested_item_location_message_for_others(
                  context.character,
                  other_msg,
                  item,
                  items_in_path,
                  false,
                  "in"
                )

              IO.inspect("other msg")

              self_msg =
                context.character.id
                |> Message.new_story_output()
                |> Message.append_text("You", "character")
                |> Message.append_text(" stow ", "base")

              self_msg =
                Util.construct_nested_item_location_message_for_self(self_msg, item, "in")

              # self_msg =
              #   context.character.id
              #   |> Message.new_story_output()
              #   |> Message.append_text("You", "character")
              #   |> Message.append_text(" stow ", "base")
              #   |> Message.append_text(
              #     thing.match.description.short,
              #     Mud.Engine.Util.get_item_type(item)
              #   )
              #   |> Message.append_text(".", "base")

              IO.inspect("self msg")

              self_msg =
                if other_matches != [] do
                  other_items = Enum.map(other_matches, & &1.match)

                  IO.inspect(self_msg, label: :other_matches)
                  IO.inspect(item, label: :other_matches)
                  IO.inspect(other_items, label: :other_matches)

                  Util.append_assumption_text(self_msg, thing.match, other_items)
                else
                  self_msg
                end

              # check to see whether the update needs to go to only inventory or the area too
              context =
                if thing.match.location.on_ground do
                  context
                  |> Context.append_event(
                    [context.character_id | others],
                    UpdateArea.new(%{action: :remove, on_ground: [thing.match]})
                  )
                  |> Context.append_event(
                    context.character_id,
                    UpdateInventory.new(:add, item)
                  )
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

            _ ->
              # There is no place to stow anything
              Context.append_message(
                context,
                Message.new_story_output(
                  context.character.id,
                  "You aren't wearing any containers to stow anything inside of. And this isn't that sort of game.",
                  "system_alert"
                )
              )
          end
        end

      not parent_containers_open and (in_area or in_hands) ->
        parent_containers = Item.list_sorted_parent_containers(thing.match)
        # If a parent is closed, warn the player
        CallbackUtil.parent_containers_closed_error(context, thing.match, parent_containers)

      not in_area and not in_hands ->
        Util.dave_error_v2(context)
    end
  end

  defp get_stow_target_container(containers, %{flags: %{armor: true}}) do
    get_container_or_default(containers, containers.armor_id)
  end

  defp get_stow_target_container(containers, %{flags: %{coin: true}}) do
    # TODO: Shove coin into wealth rather than trying to actually take the item. Do the same thing that 'get' does when encountering a coin
    get_container_or_default(containers, containers.armor_id)
  end

  defp get_stow_target_container(containers, %{flags: %{clothing: true}}) do
    get_container_or_default(containers, containers.clothing_id)
  end

  defp get_stow_target_container(containers, %{flags: %{gem: true}}) do
    # TODO: This needs special logic to check for a gem pouch, not just any worn pouch.
    get_container_or_default(containers, containers.gem_id)
  end

  defp get_stow_target_container(containers, %{flags: %{shield: true}}) do
    get_container_or_default(containers, containers.shield_id)
  end

  defp get_stow_target_container(containers, %{flags: %{weapon: true}}) do
    get_container_or_default(containers, containers.weapon_id)
  end

  defp get_stow_target_container(containers, _) do
    get_default_stow_target_container(containers)
  end

  defp get_default_stow_target_container(containers) do
    if is_nil(containers.default_id) do
      # search for all worn containers on character and grab the largest one to use
      find_largest_worn_container(containers.character_id)
    else
      target_container = Item.get!(containers.default_id)

      if Item.in_inventory?(target_container.id, containers.character_id) do
        target_container
      else
        # search for all worn containers on character and grab the largest one to use
        find_largest_worn_container(containers.character_id)
      end
    end
  end

  defp find_largest_worn_container(character_id) do
    Character.list_worn_containers(character_id)
    |> Enum.sort(&(&1.container.capacity >= &2.container.capacity))
    |> List.first()
  end

  defp get_container_or_default(containers, target_container_id) do
    if is_nil(target_container_id) do
      get_default_stow_target_container(containers)
    else
      target_container = Item.get!(target_container_id)

      if Item.in_inventory?(target_container.id, containers.character_id) do
        target_container
      else
        get_default_stow_target_container(containers)
      end
    end
  end
end
