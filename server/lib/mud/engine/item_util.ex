defmodule Mud.Engine.ItemUtil do
  @moduledoc """
  A module for breaking out item specific helper functionality to be used anywhere item helper logic might be needed.
  """

  alias Mud.Engine
  alias Mud.Engine.Message
  alias Mud.Engine.Item
  alias Mud.Engine.Command.CallbackUtil
  alias Mud.Repo
  import Ecto.Query

  @doc """
  Given a set of items, create a map where the key is the item id and the value is the item itself.
  """
  @spec build_item_index(items :: Mud.Engine.Item.t() | [Mud.Engine.Item.t()]) :: %{
          String.t() => Mud.Engine.Item.t()
        }
  def build_item_index(items) do
    items
    |> List.wrap()
    |> Enum.reduce(%{}, fn item, map -> Map.put(map, item.id, item) end)
  end

  @doc """
  Given a set of items, create a map where the key is the item id of a parent and the value is a list of all children
  of that parent. Assuming those children were given in the provided list of items, of course.
  """
  @spec build_child_index(items :: Mud.Engine.Item.t() | [Mud.Engine.Item.t()]) :: %{
          String.t() => [Mud.Engine.Item.t()]
        }
  def build_child_index(items) do
    items
    |> List.wrap()
    |> Enum.reduce(%{}, fn item, map ->
      existing_children = Map.get(map, item.location.relative_item_id, [])
      Map.put(map, item.location.relative_item_id, [item | existing_children])
    end)
  end

  @doc """
  Given a single item, determine if this item is in a position to be seen by either a generic 'look' or a targeted one.

  Visible means that an item is either held, worn, on ground, in containers that are open, or sitting on a surface
  that displays items. This must be true of all parents recursively.
  """
  def is_available_for_look?(item) do
    parents = Item.list_sorted_parent_containers(item)
    item_index = build_item_index([item | parents])

    Enum.all?([item | parents], fn parent ->
      cond do
        item.id == parent.id ->
          true

        parent.location.on_ground or parent.location.held_in_hand or
            parent.location.worn_on_character ->
          true

        item.location.relation == "on" and
            item_index[item.location.relative_item_id].surface.show_item_contents ->
          true

        item.location.relation == "in" and
            item_index[item.location.relative_item_id].pocket.open ->
          true

        true ->
          false
      end
    end)
  end

  @doc """
  Given an item, build the description for it, which includes any items which may be visibly sitting on it.

  That is determined both by item settings and the presence of children
  """
  def build_item_description(
        message,
        item = %{flags: %{has_surface: true}, surface: %{show_item_contents: true}}
      ) do
    children = Item.list_all_recursive_surface_children(item)

    build_item_description(
      message,
      item,
      build_child_index(children),
      build_item_index(children)
    )
  end

  def build_item_description(
        message,
        item
      ) do
    Message.append_text(message, item.description.short, Engine.Util.get_item_type(item))
  end

  defp build_item_description(
         message,
         item = %{flags: %{has_surface: true}, surface: %{show_item_contents: true}},
         child_index,
         item_index
       ) do
    # First thing first, append the description of the item
    message =
      if item.location.on_ground or
           item_index[item.location.relative_item_id].surface.show_detailed_items == false do
        Message.append_text(message, item.description.short, Engine.Util.get_item_type(item))
      else
        Message.append_text(message, item.description.long, Engine.Util.get_item_type(item))
      end

    # If the item being currently build up has children enter this logic, because we need more than a single item
    # description.
    if Map.has_key?(child_index, item.id) do
      # Pull out the actual children to display, and then also flag whether or not there were too many
      {children, too_many_children_to_display} =
        if length(child_index[item.id]) > item.surface.show_item_limit do
          sorted_children = CallbackUtil.sort_items(child_index[item.id], true)
          {Enum.take(sorted_children, item.surface.show_item_limit), true}
        else
          {CallbackUtil.sort_items(child_index[item.id], true), false}
        end

      message =
        Message.append_text(
          message,
          " on which sits#{
            if too_many_children_to_display do
              ", among other things,"
            end
          } ",
          "base"
        )

      Enum.reduce(children, message, fn child, message ->
        # For each child recurse so we can display things arbitrary levels deep
        build_item_description(message, child, child_index, item_index)
        |> Message.append_text(", ", "base")
      end)
      |> Message.drop_last_text()
      |> Message.maybe_add_oxford_comma()

      # If there are no children the only thing that needs to happen has already happened.
    else
      message
    end
  end

  defp build_item_description(
         message,
         item,
         _child_index,
         _item_index
       ) do
    Message.append_text(message, item.description.short, Engine.Util.get_item_type(item))
  end
end
