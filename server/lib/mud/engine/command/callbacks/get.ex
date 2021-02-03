defmodule Mud.Engine.Command.Get do
  @moduledoc """
  The GET command allows the Character to get something from the ground or relative to other items.

  Syntax:
    - get <target>

  Examples:
    - get backpack
    - get door
    - get pouch in backpack
  """

  alias Mud.Engine.Event.Client.{UpdateArea, UpdateCharacter, UpdateInventory}
  alias Mud.Engine.Search
  alias Mud.Engine.Message
  alias Mud.Engine.Util
  alias Mud.Engine.Command.CallbackUtil
  alias Mud.Engine.Command.Context
  alias Mud.Engine.{Character, Item}
  alias Item.{Container}
  alias Mud.Engine.Command.AstNode.ThingAndPlace, as: TAP
  alias Mud.Engine.Command.AstNode.{Thing, Place}
  alias Mud.Repo
  alias Mud.Engine.Item.Location

  require Logger

  use Mud.Engine.Command.Callback

  @spec build_ast([Mud.Engine.Command.AstNode.t(), ...]) ::
          Mud.Engine.Command.AstNode.ThingAndPlace.t()
  def build_ast(ast_nodes) do
    Mud.Engine.Command.AstUtil.build_tap_ast(ast_nodes)
  end

  @impl true
  def execute(context) do
    Logger.debug("Executing Get command")
    Logger.debug(inspect(context))
    ast = context.command.ast

    if is_nil(ast.thing) do
      Logger.debug("Get command entered without input. Returning error with command docs.")

      Context.append_message(
        context,
        Message.new_story_output(
          context.character.id,
          Util.get_module_docs(__MODULE__),
          "system_info"
        )
      )
    else
      # get_item_if_empty_hand(context)
      # A UUID was passed in which means the get command is being attempted on a specific item.
      # This sort of command should only be triggered by the UI.
      if Util.is_uuid4(context.command.ast.thing.input) do
        Logger.debug("Get command provided with uuid: #{context.command.ast.thing.input}")

        case Item.get(context.command.ast.thing.input) do
          {:ok, item} ->
            get_item(context, List.first(Search.things_to_match(item)))

          _ ->
            Util.dave_error_v2(context)
        end
      else
        Logger.debug("Provided input was not a uuid: #{context.command.ast.thing.input}")

        # If there is input but that input is not a UUID, that means the player typed text in. Go searching for the item.
        find_thing_to_get(context)
      end
    end
  end

  defp find_thing_to_get(context = %Mud.Engine.Command.Context{}) do
    case context.command.ast do
      # Get thing on character
      # If nothing is found worn on the character do not look further
      %TAP{place: nil, thing: %Thing{personal: true}} ->
        Logger.debug("Item to Get should be on character")

        get_item_in_inventory(context)

      # Thing being geted did not have 'my' specified, but also no place either
      %TAP{place: nil, thing: %Thing{personal: false}} ->
        get_item_in_area_or_inventory(context)

      # This thing will be in a place, but that place might not be on the character
      %TAP{place: %Place{personal: false}, thing: %Thing{personal: false}} ->
        get_item_with_place(context)

      # get thing in container on character
      %TAP{place: %Place{personal: place}, thing: %Thing{personal: thing}} when place or thing ->
        get_item_with_personal_place(context)
    end
  end

  defp get_item_in_inventory(context) do
    results =
      Search.find_matches_inside_inventory(
        context.character.id,
        context.command.ast.thing.input,
        context.character.settings.commands.search_mode
      )

    case results do
      {:ok, matches} ->
        sorted_results = CallbackUtil.sort_matches(matches)

        # then just handle results as normal
        handle_search_results(context, {:ok, sorted_results})

      _ ->
        handle_search_results(context, results)
    end
  end

  defp handle_search_results(context, results) do
    case results do
      {:ok, [match]} ->
        get_item(context, match)

      {:ok, all_matches = [match | matches]} ->
        case context.command.ast do
          # If which is greater than 0, then more than one match was anticipated.
          # Make sure provided selection is not more than the number of items that were found
          %TAP{thing: %Thing{which: which}}
          when is_integer(which) and which > 0 and which <= length(all_matches) ->
            get_item(context, Enum.at(matches, which - 1))

          # If the user provided a number but it is greater than the number of items found,
          %TAP{thing: %Thing{which: which}} when which > 0 and which > length(all_matches) ->
            Util.not_found_error(context)

          _ ->
            case context.character.settings.commands.multiple_matches_mode do
              "silent" ->
                get_item(context, match, [])

              "alert" ->
                get_item(context, match, matches)

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

  defp get_item_with_place(context) do
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
        get_item_with_personal_place(context)
    end
  end

  defp get_item_with_personal_place(context) do
    # look for item in place in inventory, but do not return items worn or held
    results =
      Search.find_matches_relative_to_place_in_inventory(
        context.character.id,
        context.command.ast.thing,
        context.command.ast.place,
        context.character.settings.commands.search_mode
      )

    handle_search_results(context, results)
  end

  defp get_item_in_area_or_inventory(context) do
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
        get_item_in_inventory(context)
    end
  end

  defp get_item(context, thing = %Search.Match{}, other_matches \\ []) do
    items_in_hands = Item.list_items_in_hands(context.character.id)

    IO.inspect(items_in_hands, label: :get_item_items_in_hands)

    if length(items_in_hands) == 2 do
      Util.hands_full_error(context)
    else
      original_item = thing.match
      in_area = Item.in_area?(original_item.id, context.character.area_id)
      in_inventory = Item.in_inventory?(original_item.id, context.character.id)
      parent_containers_open = Item.parent_containers_open?(original_item)

      IO.inspect(
        original_item,
        label: :get_item
      )

      IO.inspect(
        {in_area, in_inventory, parent_containers_open, original_item.location.held_in_hand,
         original_item.location.worn_on_character,
         parent_containers_open and
           (in_area or
              (in_inventory and
                 not (original_item.location.held_in_hand or
                        original_item.location.worn_on_character)))},
        label: :get_item
      )

      cond do
        parent_containers_open and
            (in_area or
               (in_inventory and
                  not (original_item.location.held_in_hand or
                           original_item.location.worn_on_character))) ->
          cond do
            original_item.flags.coin ->
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

            # Item can be held which means it can be picked up
            original_item.flags.hold ->
              IO.inspect(original_item, label: "getting held item")

              hand =
                cond do
                  length(items_in_hands) == 0 ->
                    context.character.handedness

                  true ->
                    if List.first(items_in_hands).location.hand == "right" do
                      "left"
                    else
                      "right"
                    end
                end

              location =
                Location.update!(original_item.location, %{
                  on_ground: false,
                  relative_to_container: false,
                  area_id: nil,
                  relative_item_id: nil,
                  held_in_hand: true,
                  character_id: context.character.id,
                  hand: hand
                })

              item = Map.put(original_item, :location, location)

              others =
                Character.list_others_active_in_areas(
                  context.character.id,
                  context.character.area_id
                )

              # TODO: Figure out only displaying the outermost container for the item, or the item itself it is the outermost container
              other_msg =
                others
                |> Message.new_story_output()
                |> Message.append_text("[#{context.character.name}]", "character")
                |> Message.append_text(" gets ", "base")
                |> Message.append_text(
                  Item.items_to_short_desc_with_nested_location_without_item(original_item),
                  Mud.Engine.Util.get_item_type(item)
                )
                |> Message.append_text(".", "base")

              self_msg =
                context.character.id
                |> Message.new_story_output()
                |> Message.append_text("You", "character")
                |> Message.append_text(" get ", "base")
                |> Message.append_text(
                  Item.items_to_short_desc_with_nested_location_without_item(original_item),
                  Mud.Engine.Util.get_item_type(item)
                )
                |> Message.append_text(".", "base")

              self_msg =
                if other_matches != [] do
                  other_items = Enum.map(other_matches, & &1.match)

                  IO.inspect(self_msg, label: :other_matches)
                  IO.inspect(item, label: :other_matches)
                  IO.inspect(other_items, label: :other_matches)

                  Util.append_assumption_text(self_msg, original_item, other_items)
                else
                  self_msg
                end

              # check to see whether the update needs to go to only inventory or the area too
              context =
                if original_item.location.on_ground do
                  context
                  |> Context.append_event(
                    [context.character_id | others],
                    UpdateArea.new(%{action: :remove, on_ground: [original_item]})
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

            not original_item.flags.hold ->
              self_msg =
                context.character.id
                |> Message.new_story_output()
                |> Message.append_text(
                  Util.upcase_first(
                    Item.items_to_short_desc_with_nested_location_without_item(original_item)
                  ),
                  Mud.Engine.Util.get_item_type(original_item)
                )
                |> Message.append_text(" cannot be picked up.", "system_alert")

              Context.append_message(context, self_msg)
          end

        not parent_containers_open and
            (in_area or
               (in_inventory and
                  not (original_item.location.held_in_hand or
                           original_item.location.worn_on_character))) ->
          parent_containers = Item.list_sorted_parent_containers(original_item)
          # If a parent is closed, warn the player
          CallbackUtil.parent_containers_closed_error(context, original_item, parent_containers)

        in_inventory and original_item.location.held_in_hand ->
          self_msg =
            context.character.id
            |> Message.new_story_output()
            |> Message.append_text("You", "character")
            |> Message.append_text(" are already holding ", "base")
            |> Message.append_text(
              original_item.description.short,
              Mud.Engine.Util.get_item_type(original_item)
            )
            |> Message.append_text(".", "base")

          Context.append_message(context, self_msg)

        in_inventory and original_item.location.worn_on_character ->
          self_msg =
            context.character.id
            |> Message.new_story_output()
            |> Message.append_text("You", "character")
            |> Message.append_text(" are wearing ", "base")
            |> Message.append_text(
              original_item.description.short,
              Mud.Engine.Util.get_item_type(original_item)
            )
            |> Message.append_text(". If you wish, you may REMOVE it instead.", "base")

          Context.append_message(context, self_msg)

        not in_area and not in_inventory ->
          Util.dave_error_v2(context)
      end
    end
  end
end
