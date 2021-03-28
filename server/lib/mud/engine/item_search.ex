defmodule Mud.Engine.ItemSearch do
  @moduledoc """
  Helper module for Items which contains all of the different, specific, searches that might need to be made.any()
  """

  alias Mud.Engine.Item
  alias Mud.Engine.Item.{Location}
  alias Mud.Engine.Search
  alias Mud.Repo
  import Ecto.Query

  #
  #
  # API
  #
  #

  @doc """
  Search for an item that is a child of another item.
  """
  def search_relative_to_item_in_area(
        area_id,
        [initial_path | path],
        thing,
        mode,
        thing_is_immediate_child \\ true
      ) do
    # Initial path is the outermost item, so if doing 'get ring on box in vault' the initial path would be the vault
    initial_query =
      specific_nested_item_in_area_initial_query(
        area_id,
        Search.input_to_wildcard_string(initial_path.input, mode)
      )

    build_and_execute_relative_query(initial_query, path, thing, thing_is_immediate_child)
  end

  defp specific_nested_item_in_area_initial_query(
         area_id,
         search_string
       ) do
    from(
      [location: location] in base_query_for_description_and_location(),
      where: location.item_id in subquery(base_query_for_all_area_item_ids(area_id))
    )
    |> modify_query_search_descriptions(search_string)
    |> modify_query_select_id()
  end

  defp build_and_execute_relative_query(
         initial_query,
         path,
         thing,
         thing_is_immediate_child
       ) do
    mostly_constructed_query = build_nested_relative_query(initial_query, path)

    final_query =
      specific_nested_item_top_level_query(
        mostly_constructed_query,
        Search.input_to_wildcard_string(thing.input),
        thing.where,
        thing_is_immediate_child
      )

    Repo.all(final_query)
    |> Item.preload()
  end

  defp specific_nested_item_top_level_query(
         previous_query,
         search_string,
         relation,
         thing_is_immediate_child
       ) do
    query =
      if thing_is_immediate_child do
        child_ids_query(previous_query)
      else
        recursive_child_ids_query(previous_query)
      end

    from(
      [location: location] in base_query_for_description_and_location(),
      where:
        location.relative_to_item and location.item_id in subquery(query) and
          location.relation == ^relation
    )
    |> modify_query_search_descriptions(search_string)
  end

  defp child_ids_query(ids) do
    from([location: location] in child_query(ids), select: location.item_id)
  end

  defp child_query(ids) do
    if is_list(ids) do
      from(
        [location: location] in base_query_for_description_and_location(),
        where: location.relative_to_item and location.relative_item_id in ^ids
      )
    else
      from(
        [location: location] in base_query_for_description_and_location(),
        where: location.relative_to_item and location.relative_item_id in subquery(ids)
      )
    end
  end

  defp build_nested_relative_query(previous_query, []) do
    previous_query
  end

  defp build_nested_relative_query(previous_query, [current_path | path]) do
    IO.inspect(current_path, label: :build_nested_relative_query)

    current_query =
      specific_nested_item_mid_level_query(
        previous_query,
        Search.input_to_wildcard_string(current_path.input),
        current_path.where
      )

    build_nested_relative_query(current_query, path)
  end

  def specific_nested_item_mid_level_query(
        previous_query,
        search_string,
        relation
      ) do
    from(
      [location: location] in base_query_for_description_and_location(),
      where:
        location.relative_to_item and
          location.item_id in subquery(
            immediate_children_with_relationship_and_all_nested_child_ids_query(
              previous_query,
              relation
            )
          )
    )
    |> modify_query_search_descriptions(search_string)
    |> modify_query_select_id()
  end

  defp recursive_child_ids_query(ids) do
    from(location in recursive_child_query(ids), select: location.item_id)
  end

  defp base_query_for_all_area_item_ids(area_id) do
    base_query_for_all_area_items(area_id)
    |> modify_query_select_item_id()
  end

  defp base_query_for_all_area_items(area_id) do
    recursive_child_query(base_query_for_root_area_item_ids(area_id))
  end

  defp base_query_for_root_area_item_ids(area_id) do
    base_query_for_root_area_items(area_id)
    |> modify_query_select_id()
  end

  defp base_query_for_root_area_items(area_id) do
    from(
      [location: location] in base_query_for_description_and_location(),
      where: location.on_ground and location.area_id == ^area_id
    )
  end

  @doc """
  Items on ground are searched for a match.
  """
  def search_on_ground(area_id, search_string) do
    from(
      [description: description, location: location] in base_query_for_description_and_location(),
      where: location.area_id == ^area_id and location.on_ground,
      order_by: [desc: location.moved_at]
    )
    |> modify_query_search_descriptions(search_string)
    |> Repo.all()
    |> Item.preload()
  end

  @doc """
  All inventory items are searched, worn and then everything inside, for a match.
  """
  @spec search_inventory(String.t(), String.t()) :: [Mud.Engine.Item.t()]
  def search_inventory(character_id, search_string) do
    search_inventory_query(character_id, search_string)
    |> modify_query_search_descriptions(search_string)
    |> Repo.all()
    |> Item.preload()
  end

  @doc """
  All surfaces visible in an area, but not the root items on the ground, are searched for a match.
  """
  @spec search_on_visible_surfaces_in_area(String.t(), String.t()) :: [Mud.Engine.Item.t()]
  def search_on_visible_surfaces_in_area(area_id, search_string) do
    search_for_items_on_visible_surfaces_in_area_query(area_id)
    |> modify_query_search_descriptions(search_string)
    |> Repo.all()
    |> Item.preload()
  end

  #
  #
  # Helper/Internal Functions
  #
  #

  defp search_for_items_on_visible_surfaces_in_area_query(area_id) do
    from(
      [location: location] in base_query_for_description_and_location(),
      where:
        location.item_id in subquery(base_query_for_all_children_on_surfaces_in_area_ids(area_id)),
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

  # All queries which need to check item descriptions should go through this modifier function
  # It checks short and long descriptions as well as enforcing that at least one of the "words"
  # entered matches, via a fuzzy regex, the key for an item to help against false positives.
  defp modify_query_search_descriptions(query, search_string) do
    key_string =
      String.split(search_string, "%", trim: true)
      |> Enum.map(&".*#{&1}.*")
      |> Enum.join("|")

    key_regex = "^(#{key_string})$"

    from(
      [description: description] in query,
      where:
        (like(description.short, ^search_string) or like(description.long, ^search_string)) and
          fragment("? ~* ?", description.key, ^key_regex)
    )
  end

  defp immediate_children_with_relationship_and_all_nested_child_ids_query(ids, relationship) do
    children_ids_query =
      from([item, location: location] in base_query_for_description_and_location(),
        where: item.id in subquery(child_ids_query(ids)) and location.relation == ^relationship
      )
      |> modify_query_select_id()

    recursive_child_ids_query(children_ids_query)
  end

  defp modify_query_select_id(query) do
    from([item] in query, select: item.id)
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

  defp base_query_for_items_on_ground(area_id) do
    from(
      [location: location] in base_query(),
      where: location.area_id == ^area_id and location.on_ground
    )
  end

  defp base_query_for_items_on_ground_ids(area_id) do
    base_query_for_items_on_ground(area_id)
    |> modify_query_select_id()
  end

  defp base_query_for_all_children_on_surfaces_in_area_ids(area_id) do
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
      left_join: closable in assoc(item, :closable),
      as: :closable,
      left_join: coin in assoc(item, :coin),
      as: :coin,
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
      left_join: lockable in assoc(item, :lockable),
      as: :lockable,
      left_join: physics in assoc(item, :physics),
      as: :physics,
      left_join: pocket in assoc(item, :pocket),
      as: :pocket,
      left_join: surface in assoc(item, :surface),
      as: :surface,
      left_join: wearable in assoc(item, :wearable),
      as: :wearable
    )
  end
end
