defmodule Mud.Engine.Command.Close do
  @moduledoc """
  The CLOSE command allows the Character to close something such as a door or a chest.

  Syntax:
    - close <target>

  Examples:
    - close backpack
    - close door
    - close pouch in backpack
  """

  alias Mud.Engine.Event.Client.{UpdateArea, UpdateInventory}
  alias Mud.Engine.Search
  alias Mud.Engine.Message
  alias Mud.Engine.Util
  alias Mud.Engine.Command.Context
  alias Mud.Engine.{Character, Item}
  alias Item.{Container}
  alias Mud.Engine.Command.AstNode.ThingAndPlace, as: TAP
  alias Mud.Engine.Command.AstNode.{Thing, Place}

  require Logger

  use Mud.Engine.Command.Callback

  @spec build_ast([Mud.Engine.Command.AstNode.t(), ...]) ::
          Mud.Engine.Command.AstNode.ThingAndPlace.t()
  def build_ast(ast_nodes) do
    Mud.Engine.Command.AstUtil.build_tap_ast(ast_nodes)
  end

  @impl true
  def execute(context) do
    Logger.debug("Executing Close command")
    Logger.debug(inspect(context))
    ast = context.command.ast

    if is_nil(ast.thing) do
      Logger.debug("Close command entered without input. Returning error with command docs.")

      Context.append_output(
        context,
        context.character.id,
        Util.get_module_docs(__MODULE__),
        "error"
      )
    else
      # A UUID was passed in which means the close command is being attempted on a specific item.
      # This sort of command should only be triggered by the UI.
      if Util.is_uuid4(context.command.ast.thing.input) do
        Logger.debug("Close command provided with uuid: #{context.command.ast.thing.input}")

        case Item.get(context.command.ast.thing.input) do
          {:ok, item} ->
            close_item(context, List.first(Search.things_to_match(item)))

          _ ->
            Util.dave_error_v2(context)
        end
      else
        Logger.debug("Provided input was not a uuid: #{context.command.ast.thing.input}")

        # If there is input but that input is not a UUID, that means the player typed text in. Go searching for the item.
        find_thing_to_close(context)
      end
    end
  end

  defp find_thing_to_close(context = %Mud.Engine.Command.Context{}) do
    case context.command.ast do
      # Close thing on character
      # If nothing is found worn on the character do not look further
      %TAP{place: nil, thing: %Thing{personal: true}} ->
        Logger.debug("Item to Close should be on character")

        # close_worn_or_held_item_in_inventory(context)
        close_item_in_inventory(context)

      # Thing being closeed did not have 'my' specified, but also no place either
      %TAP{place: nil, thing: %Thing{personal: false}} ->
        close_item_in_area_or_inventory(context)

      # This thing will be in a place, but that place might not be on the character
      %TAP{place: %Place{personal: false}, thing: %Thing{personal: false}} ->
        close_item_with_place(context)

      # close thing in container on character
      %TAP{place: %Place{personal: place}, thing: %Thing{personal: thing}} when place or thing ->
        close_item_with_personal_place(context)
    end
  end

  defp close_item_in_inventory(context) do
    results =
      Search.find_matches_in_inventory(
        context.character.id,
        context.command.ast.thing.input,
        context.character.settings.commands.search_mode
      )

    case results do
      {:ok, matches} ->
        sorted_results = sort_items(matches)

        # then just handle results as normal
        handle_search_results(context, {:ok, sorted_results})

      _ ->
        handle_search_results(context, results)
    end
  end

  defp sort_items(matches) do
    ancestors = Item.list_all_parents(Enum.map(matches, & &1.match))

    # create ancestor tree index
    parent_index =
      Enum.reduce(ancestors, %{}, fn item, index ->
        cond do
          item.location.relative_to_item ->
            Map.put(index, item.id, item.location.relative_item_id)

          item.location.worn_on_character ->
            Map.put(index, item.id, "worn")

          item.location.held_in_hand ->
            Map.put(index, item.id, "held")

          item.flags.scenery ->
            Map.put(index, item.id, "scenery")

          item.location.on_ground ->
            Map.put(index, item.id, "ground")
        end
      end)

    # create ancestor tree index
    parent_move_index =
      Enum.reduce(ancestors, %{}, fn item, index ->
        Map.put(index, item.id, item.location.moved_at)
      end)

    layer_index =
      Enum.reduce(ancestors, %{}, fn item, index ->
        cond do
          item.location.relative_to_item ->
            Map.put(
              index,
              item.id,
              count_layers(item.location.relative_item_id, parent_index)
            )

          item.location.on_ground or item.location.worn_on_character or
              item.location.held_in_hand ->
            Map.put(index, item.id, 0)
        end
      end)

    # sort by this

    roots = ["ground", "scenery", "held", "worn"]

    Enum.sort(matches, fn match1, match2 ->
      item1 = match1.match
      item2 = match2.match

      cond do
        # both items are root inventory items
        layer_index[item1.id] == 0 and layer_index[item2.id] == 0 ->
          cond do
            # different layers with item1 being held and item2 worn
            Enum.find_index(roots, &(&1 == parent_index[item1.id])) <
                Enum.find_index(roots, &(&1 == parent_index[item2.id])) ->
              true

            # different layers with item2 being held and item1 worn
            Enum.find_index(roots, &(&1 == parent_index[item1.id])) >
                Enum.find_index(roots, &(&1 == parent_index[item2.id])) ->
              false

            # both on the same root layer, so can go by when they were last moved
            Enum.find_index(roots, &(&1 == parent_index[item1.id])) ==
                Enum.find_index(roots, &(&1 == parent_index[item2.id])) ->
              item1.location.moved_at <= item2.location.moved_at
          end

        layer_index[item1.id] == layer_index[item2.id] ->
          if item1.location.relative_item_id == item2.location.relative_item_id do
            # same layer same parent go by own sort order
            item1.location.moved_at <= item2.location.moved_at
          else
            # same layer different parents go by parents sort order
            parent_move_index[item1.location.relative_item_id] <=
              parent_move_index[item2.location.relative_item_id]
          end

        # different layers go by layer order
        layer_index[item1.id] < layer_index[item2.id] ->
          true

        # different layers go by layer order
        layer_index[item1.id] > layer_index[item2.id] ->
          false
      end
    end)
  end

  defp count_layers(_parent_id, _parent_index, _current_layer \\ 0)

  defp count_layers(nil, _parent_index, _current_layer) do
    0
  end

  defp count_layers(parent_id, parent_index, current_layer) do
    result = Map.get(parent_index, parent_id)

    if result in ["worn", "held", "ground"] do
      current_layer
    else
      count_layers(result, parent_index, current_layer + 1)
    end
  end

  defp handle_search_results(context, results) do
    case results do
      {:ok, [match]} ->
        close_item(context, match)

      {:ok, all_matches = [match | matches]} ->
        case context.command.ast do
          # If which is greater than 0, then more than one match was anticipated.
          # Make sure provided selection is not more than the number of items that were found
          %TAP{thing: %Thing{which: which}}
          when is_integer(which) and which > 0 and which <= length(all_matches) ->
            close_item(context, Enum.at(matches, which - 1))

          # If the user provided a number but it is greater than the number of items found,
          %TAP{thing: %Thing{which: which}} when which > 0 and which > length(all_matches) ->
            Util.not_found_error(context)

          _ ->
            case context.character.settings.commands.multiple_matches_mode do
              "silent" ->
                close_item(context, match, [])

              "alert" ->
                close_item(context, match, matches)

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

  defp close_item_with_place(context) do
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
        handle_search_results(context, {:ok, sort_items(area_matches)})

      _ ->
        close_item_with_personal_place(context)
    end
  end

  defp close_item_with_personal_place(context) do
    # look for place on ground on in hands or worn
    results =
      Search.find_matches_relative_to_place_in_inventory(
        context.character.id,
        context.command.ast.thing,
        context.command.ast.place,
        context.character.settings.commands.search_mode
      )

    handle_search_results(context, results)
  end

  defp close_item_in_area_or_inventory(context) do
    area_results =
      Search.find_matches_in_area(
        context.character.area_id,
        context.command.ast.thing.input,
        context.character.settings.commands.search_mode
      )

    case area_results do
      {:ok, area_matches} when area_matches != [] ->
        IO.inspect(area_matches, label: :area_matches)
        handle_search_results(context, {:ok, sort_items(area_matches)})

      _ ->
        close_item_in_inventory(context)
    end
  end

  defp close_item(context, thing = %Search.Match{}, other_matches \\ []) do
    in_area = Item.in_area?(thing.match.id, context.character.area_id)
    in_inventory = Item.in_inventory?(thing.match.id, context.character.id)
    parent_containers_open = Item.parent_containers_open?(thing.match)

    cond do
      parent_containers_open and (in_area or in_inventory) ->
        cond do
          # Is container and container is open, meaning it can be closed
          thing.match.flags.container and thing.match.container.open ->
            container =
              Container.update!(thing.match.container, %{
                open: false
              })

            item = Map.put(thing.match, :container, container)

            others =
              Character.list_others_active_in_areas(
                context.character.id,
                context.character.area_id
              )

            other_msg =
              others
              |> Message.new_story_output()
              |> Message.append_text("[#{context.character.name}]", "character")
              |> Message.append_text(" closes ", "base")
              |> Message.append_text(item.description.short, Mud.Engine.Util.get_item_type(item))
              |> Message.append_text(".", "base")

            self_msg =
              context.character.id
              |> Message.new_story_output()
              |> Message.append_text("You", "character")
              |> Message.append_text(" close ", "base")
              |> Message.append_text(
                Item.items_to_short_desc_with_nested_location(item),
                Mud.Engine.Util.get_item_type(item)
              )
              |> Message.append_text(".", "base")

            self_msg =
              if other_matches != [] do
                other_items = Enum.map(other_matches, & &1.match)

                Util.append_assumption_text(self_msg, item, other_items)
              else
                self_msg
              end

            # for items that are not root items, check to see whether the update needs to go to inventory or the area
            context =
              cond do
                item.location.worn_on_character or item.location.held_in_hand or
                    in_inventory ->
                  Context.append_event(
                    context,
                    context.character_id,
                    UpdateInventory.new(:update, item)
                  )

                item.location.on_ground ->
                  Context.append_event(
                    context,
                    [context.character_id | others],
                    UpdateArea.new(%{action: :update, on_ground: [item]})
                  )
              end

            context
            |> Context.append_message(other_msg)
            |> Context.append_message(self_msg)

          # It is a container but the container is close,
          thing.match.flags.container and not thing.match.container.open ->
            self_msg =
              context.character.id
              |> Message.new_story_output()
              |> Message.append_text(
                upcase_item_with_location(thing.match),
                Mud.Engine.Util.get_item_type(thing.match)
              )
              |> Message.append_text(" is already closed.", "system_warning")

            self_msg =
              if other_matches != [] do
                other_items = Enum.map(other_matches, & &1.match)

                Util.append_assumption_text(self_msg, thing.match, other_items)
              else
                self_msg
              end

            Context.append_message(context, self_msg)

          # Assume the thing is not a container
          true ->
            self_msg =
              context.character.id
              |> Message.new_story_output()
              |> Message.append_text(
                upcase_item_with_location(thing.match),
                Mud.Engine.Util.get_item_type(thing.match)
              )
              |> Message.append_text(" cannot be closeed.", "system_alert")

            self_msg =
              if other_matches != [] do
                other_items = Enum.map(other_matches, & &1.match)

                Util.append_assumption_text(self_msg, thing.match, other_items)
              else
                self_msg
              end

            Context.append_message(context, self_msg)
        end

      not parent_containers_open and (in_area or in_inventory) ->
        # If a parent is closed, warn the player
        Util.parent_container_closed_error(context)

      not in_area and not in_inventory ->
        Util.dave_error_v2(context)
    end
  end

  defp upcase_item_with_location(item) do
    Util.upcase_first(Item.items_to_short_desc_with_nested_location(item))
  end
end
