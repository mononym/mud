defmodule Mud.Engine.ItemUtil do
  @moduledoc """
  A module for breaking out item specific helper functionality to be used anywhere item helper logic might be needed.
  """

  alias Mud.Engine
  alias Mud.Engine.Message
  alias Mud.Engine.Item
  alias Mud.Engine.ItemSearch
  alias Mud.Engine.Command.CallbackUtil

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

  If an item is available for look it is usually available for quite a few other actions as well.
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

        parent.location.relative_to_item and parent.location.relation == "on" ->
          true

        parent.location.relative_to_item and parent.location.relation == "in" and
            (not item_index[parent.location.relative_item_id].flags.is_closable or
               (item_index[parent.location.relative_item_id].flags.is_closable and
                  item_index[parent.location.relative_item_id].closable.open)) ->
          true

        true ->
          false
      end
    end)
  end

  @doc """
  Given an item, or a list of items, ensure they will fit onto an item with a surface in every possible way.
  """
  @spec items_fit_on_surface(
          Mud.Engine.Item.t() | [Mud.Engine.Item.t()],
          Mud.Engine.Item.t()
        ) :: true | {:error, :count | :dimensions | :weight}
  def items_fit_on_surface(items_being_placed, item_with_surface) do
    items_being_placed = List.wrap(items_being_placed)

    with true <-
           items_fit_surface_by_dimensions(
             Enum.map(items_being_placed, & &1.physics),
             item_with_surface.surface
           ),
         true <-
           items_fit_surface_by_weight(
             Enum.map(items_being_placed, & &1.physics),
             item_with_surface.surface
           ),
         true <- items_fit_surface_by_count(items_being_placed, item_with_surface.surface) do
      true
    else
      err -> err
    end
  end

  defp items_fit_surface_by_dimensions(items_physics, surface) do
    [surface1, surface2] = [surface.width, surface.length] |> Enum.sort(:desc)

    Enum.all?(items_physics, fn item_physics ->
      [item1, item2] = [item_physics.width, item_physics.length] |> Enum.sort(:desc)

      ((item1 <= surface1 or surface2 == 0) and (item2 <= surface2 or surface1 == 0)) ||
        {:error, :dimensions}
    end)
  end

  defp items_fit_surface_by_weight(items_physics, surface) do
    if surface.item_weight_limit == 0 do
      true
    else
      existing_weight = get_weight_of_children(surface.item_id, "on")

      new_weight = Enum.reduce(items_physics, 0, &(&1.weight + &2))

      existing_weight + new_weight <= surface.item_weight_limit || {:error, :weight}
    end
  end

  defp items_fit_surface_by_count(items, surface) do
    if surface.item_count_limit == 0 do
      true
    else
      existing_item_count =
        ItemSearch.count_of_immediate_children_with_relationship(surface.item_id, "on")

      existing_item_count + length(items) <= surface.item_count_limit || {:error, :count}
    end
  end

  @doc """
  Given an item, or a list of items, ensure they will fit into an item with a pocket in every possible way.
  """
  @spec items_fit_in_pocket(
          Mud.Engine.Item.t() | [Mud.Engine.Item.t()],
          Mud.Engine.Item.t()
        ) :: true | {:error, :count | :dimensions | :weight}
  def items_fit_in_pocket(items_being_placed, item_with_pocket) do
    items_being_placed = List.wrap(items_being_placed)

    with true <-
           items_fit_pocket_by_dimensions(
             Enum.map(items_being_placed, & &1.physics),
             item_with_pocket.pocket
           ),
         true <-
           items_fit_pocket_by_weight(
             Enum.map(items_being_placed, & &1.physics),
             item_with_pocket.pocket
           ),
         true <- items_fit_pocket_by_count(items_being_placed, item_with_pocket.pocket) do
      true
    else
      err -> err
    end
  end

  defp items_fit_pocket_by_dimensions(items_physics, pocket) do
    [pocket1, pocket2, pocket3] = [pocket.width, pocket.height, pocket.length] |> Enum.sort(:desc)

    Enum.all?(items_physics, fn item_physics ->
      [item1, item2, _] =
        [item_physics.width, item_physics.height, item_physics.length] |> Enum.sort(:desc)

      ((item1 <= pocket1 or pocket3 == 0) and (item2 <= pocket2 or pocket2 == 0)) ||
        {:error, :dimensions}
    end)
  end

  defp items_fit_pocket_by_weight(items_physics, pocket) do
    if pocket.capacity == 0 do
      true
    else
      existing_weight = get_weight_of_children(pocket.item_id, "in")

      new_weight = Enum.reduce(items_physics, 0, &(&1.weight + &2))

      existing_weight + new_weight <= pocket.capacity || {:error, :weight}
    end
  end

  defp items_fit_pocket_by_count(items, pocket) do
    if pocket.item_limit == 0 do
      true
    else
      existing_item_count =
        ItemSearch.count_of_immediate_children_with_relationship(pocket.item_id, "in")

      existing_item_count + length(items) <= pocket.item_limit || {:error, :count}
    end
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

  def get_weight_of_children(item_id, place) do
    ItemSearch.weight_of_immediate_children_with_relationship(
      item_id,
      place
    )
  end
end
