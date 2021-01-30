defmodule Mud.Engine.Command.CallbackUtil do
  @moduledoc """
  Helper functions for callbacks.

  These primarily help with responses/common logic for command callbacks rather than helping with Engine logic.
  """

  alias Mud.Engine
  alias Mud.Engine.Command.Context
  alias Mud.Engine.Message

  def parent_containers_closed_error(context, item, parents) do
    msg =
      case parents do
        [_] ->
          "is inside a closed container:"

        _ ->
          "is inside multiple containers, at least one of them closed:"
      end

    message =
      context.character.id
      |> Message.new_story_output()
      |> Message.append_text(
        "#{Engine.Util.upcase_first(item.description.short)} #{msg} #{
          build_open_closed_nested_text(parents)
        }",
        "system_alert"
      )

    Context.append_message(context, message)
  end

  def build_open_closed_nested_text(containers) do
    containers
    |> Stream.map(fn item ->
      if item.location.relative_to_item do
        "#{item.description.short} (#{
          if item.container.open do
            "open"
          else
            "closed"
          end
        }) #{item.location.relation}"
      else
        "#{item.description.short} (#{
          if item.container.open do
            "open"
          else
            "closed"
          end
        })"
      end
    end)
    |> Enum.join(" ")
  end

  @doc """
  Given an item, return a string with the first letter capitalized and the full path of the item to the root.
  """
  def upcase_item_with_location(item) do
    Engine.Util.upcase_first(Item.items_to_short_desc_with_nested_location(item))
  end

  def sort_items(items) do
    ancestors = Item.list_all_parents(items)

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

    Enum.sort(items, fn item1, item2 ->
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
end
