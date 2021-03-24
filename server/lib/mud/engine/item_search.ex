defmodule Mud.Engine.ItemSearch do
  @moduledoc """
  Helper module for Items which contains all of the different, specific, searches that might need to be made.any()
  """

  alias Mud.Engine.Item
  alias Mud.Engine.Item.{Description, Location}
  alias Mud.Repo
  import Ecto.Query

  #
  #
  # API
  #
  #

  @doc """
  All inventory items are searched for a match in the Repo using the search_string as part of a LIKE query.
  """
  @spec search_inventory(String.t(), String.t()) :: [Mud.Engine.Item.t()]
  def search_inventory(character_id, search_string) do
    search_inventory_query(character_id, search_string)
    |> Repo.all()
    |> Item.preload()
  end

  @doc """
  All surfaces visible in an area are searched for a match in the Repo using the search_string as part of a LIKE query.
  """
  @spec search_on_visible_surfaces_in_area(String.t(), String.t()) :: [Mud.Engine.Item.t()]
  def search_on_visible_surfaces_in_area(area_id, search_string) do
    search_for_items_on_visible_surfaces_query(area_id, search_string)
    |> Repo.all()
    |> Item.preload()
  end

  #
  #
  # Helper/Internal Functions
  #
  #

  def search_for_items_on_visible_surfaces_query(area_id, search_string) do
    from(
      [description: description, location: location] in base_query_for_description_and_location(),
      where:
        description.item_id in subquery(base_query_for_all_children_on_surfaces_ids(area_id)) and
          like(description.short, ^search_string),
      order_by: [desc: location.moved_at]
    )
  end

  defp search_inventory_query(character_id, search_string) do
    from(
      [description: description, location: location] in base_query_for_description_and_location(),
      where:
        description.item_id in subquery(base_query_for_all_inventory_ids(character_id)) and
          like(description.short, ^search_string),
      order_by: [desc: location.moved_at]
    )
  end

  defp base_query_for_description_and_location() do
    from(
      item in Mud.Engine.Item,
      left_join: location in assoc(item, :location),
      as: :location,
      left_join: description in assoc(item, :description),
      as: :description
    )
  end

  defp base_query_for_all_inventory_ids(character_id) do
    base_query_for_all_inventory(character_id)
    |> modify_query_select_item_id()
  end

  defp modify_query_select_item_id(query) do
    from(location in query, select: location.item_id)
  end

  defp modify_query_select_id(query) do
    from(item in query, select: item.id)
  end

  defp base_query_for_root_inventory_ids(character_id) do
    base_query_for_root_inventory(character_id)
    |> modify_query_select_id()
  end

  defp base_query_for_root_inventory(character_id) do
    from(
      [location: location] in base_query(),
      where:
        (location.held_in_hand or location.worn_on_character) and
          location.character_id == ^character_id
    )
  end

  def base_query_for_items_on_ground_ids(area_id) do
    from(
      [location: location] in base_query(),
      where: location.area_id == ^area_id and location.on_ground
    )
    |> modify_query_select_id()
  end

  def base_query_for_all_children_on_surfaces_ids(area_id) do
    from(
      location in recursive_surface_child_query(base_query_for_items_on_ground_ids(area_id)),
      where: location.on_ground == false
    )
    |> modify_query_select_item_id()
  end

  defp base_query_for_all_inventory(character_id) do
    recursive_child_query(base_query_for_root_inventory_ids(character_id))
  end

  defp recursive_surface_child_query(maybe_subqry) do
    item_tree_initial_query =
      if is_list(maybe_subqry) do
        Location
        |> where(
          [l],
          l.item_id in ^maybe_subqry
        )
      else
        Location
        |> where(
          [l],
          l.item_id in subquery(maybe_subqry)
        )
      end

    item_tree_recursion_query =
      Location
      |> join(
        :inner,
        [location],
        lt in "location_tree",
        on: location.relative_item_id == lt.item_id and location.relation == "on"
      )

    item_tree_query =
      item_tree_initial_query
      |> union_all(^item_tree_recursion_query)

    {"location_tree", Location}
    |> recursive_ctes(true)
    |> with_cte("location_tree", as: ^item_tree_query)
  end

  defp recursive_child_query(maybe_subqry) do
    item_tree_initial_query =
      if is_list(maybe_subqry) do
        Location
        |> where(
          [l],
          l.item_id in ^maybe_subqry
        )
      else
        Location
        |> where(
          [l],
          l.item_id in subquery(maybe_subqry)
        )
      end

    item_tree_recursion_query =
      Location
      |> join(
        :inner,
        [location],
        lt in "location_tree",
        on: location.relative_item_id == lt.item_id
      )

    item_tree_query =
      item_tree_initial_query
      |> union_all(^item_tree_recursion_query)

    {"location_tree", Location}
    |> recursive_ctes(true)
    |> with_cte("location_tree", as: ^item_tree_query)
  end

  defp base_query() do
    from(
      item in Item,
      left_join: coin in assoc(item, :coin),
      as: :coin,
      left_join: container in assoc(item, :container),
      as: :container,
      left_join: description in assoc(item, :description),
      as: :description,
      left_join: flags in assoc(item, :flags),
      as: :flags,
      left_join: furniture in assoc(item, :furniture),
      as: :furniture,
      left_join: gem in assoc(item, :gem),
      as: :gem,
      left_join: location in assoc(item, :location),
      as: :location,
      left_join: physics in assoc(item, :physics),
      as: :physics,
      left_join: surface in assoc(item, :surface),
      as: :surface,
      left_join: wearable in assoc(item, :wearable),
      as: :wearable
    )
  end
end
