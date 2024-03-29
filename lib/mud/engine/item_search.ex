defmodule Mud.Engine.ItemSearch do
  @moduledoc """
  Helper module for Items which contains all of the different, specific, searches that might need to be made.
  """

  alias Mud.Engine.Item
  alias Mud.Engine.ItemUtil
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
  Search for an item in the character's hands.
  """
  def search_relative_to_held(
        character_id,
        [initial_path | path],
        thing,
        mode
      ) do
    search_string = Search.input_to_wildcard_string(initial_path.input, mode)

    base_items =
      search_held_query(character_id)
      |> modify_query_search_descriptions(search_string)
      |> Repo.all()

    search_for_child(initial_path, base_items, path, thing, mode, false)
  end

  @doc """
  Search for an item in the character's hands.
  """
  @spec search_held_and_all_nested_children(String.t(), String.t()) :: [Mud.Engine.Item.t()]
  def search_held_and_all_nested_children(character_id, search_string) do
    initial_query = search_held_query(character_id) |> modify_query_select_id()

    from([item, location: location] in base_query_for_description_and_location(),
      where: item.id in subquery(modify_query_select_id(recursive_child_query(initial_query)))
    )
    |> modify_query_search_descriptions(search_string)
    |> Repo.all()
    |> Item.preload()
    |> ItemUtil.sort_items(true)
  end

  @doc """
  Search for an item in the character's hands.
  """
  @spec search_held(String.t(), String.t()) :: [Mud.Engine.Item.t()]
  def search_held(character_id, search_string) do
    search_held_query(character_id)
    |> modify_query_search_descriptions(search_string)
    |> Repo.all()
    |> Item.preload()
    |> ItemUtil.sort_items(true)
  end

  defp search_held_query(character_id) do
    from(
      [location: location] in base_query_for_description_and_location(),
      where: location.item_id in subquery(base_query_for_held_item_ids(character_id)),
      order_by: [desc: location.moved_at]
    )
  end

  defp base_query_for_held_item_ids(character_id) do
    base_query_for_held_items(character_id)
    |> modify_query_select_id()
  end

  def base_query_for_held_items(character_id) do
    from(
      [location: location] in base_query_for_description_and_location(),
      where: location.held_in_hand and location.character_id == ^character_id
    )
  end

  @doc """
  Search for an item that is a child of another item.
  """
  def search_relative_to_item_in_inventory(
        character_id,
        [initial_path | path],
        thing,
        mode,
        thing_is_immediate_child \\ true
      ) do
    search_string = Search.input_to_wildcard_string(initial_path.input, mode)

    base_items =
      base_query_for_all_inventory(character_id)
      |> modify_query_search_descriptions(search_string)
      |> Repo.all()

    search_for_child(initial_path, base_items, path, thing, mode, thing_is_immediate_child)
  end

  @doc """
  Search for an item that is a child of another item in the inventory, and that has a pocket.
  """
  def search_for_pocket_relative_to_item_in_inventory(
        character_id,
        path,
        thing,
        mode,
        thing_is_immediate_child \\ true
      ) do
    search_relative_to_item_in_inventory(
      character_id,
      path,
      thing,
      mode,
      thing_is_immediate_child
    )
    |> Enum.filter(& &1.flags.has_pocket)
  end

  @doc """
  The item being searched for is not only in the inventory but also has a pocket.

  This was introduced to support 'STOW' by helping find a container to put an item in.
  """
  def search_inventory_for_item_with_pocket(character_id, search_string, mode) do
    from(
      [location: location, flags: flags] in base_query_for_description_and_location_and_flags(),
      where:
        location.item_id in subquery(base_query_for_all_inventory_ids(character_id)) and
          flags.has_pocket,
      order_by: [desc: location.moved_at]
    )
    |> modify_query_search_descriptions(Search.input_to_wildcard_string(search_string, mode))
    |> Repo.all()
    |> Item.preload()
    |> ItemUtil.sort_items(true)
  end

  @doc """
  Search for an item that is a child of another item, where the parent is on the ground.
  """
  def search_relative_to_item_on_ground(
        area_id,
        [initial_path | path],
        thing,
        mode,
        thing_is_immediate_child \\ true
      ) do
    search_string = Search.input_to_wildcard_string(initial_path.input, mode)

    base_items =
      base_on_ground_query(area_id)
      |> modify_query_search_descriptions(search_string)
      |> Repo.all()

    search_for_child(initial_path, base_items, path, thing, mode, thing_is_immediate_child)
  end

  @doc """
  Search for an item that is a child of another item somewhere in the area.

  Does not pay any attention to locked containers or anything, just that an item is or is not a child of another item.

  Any filtering and validating that an item can really be accessed will need to be done afterwards.
  """
  def search_relative_to_any_area_item(
        area_id,
        [initial_path | path],
        thing,
        mode,
        thing_is_immediate_child \\ true
      ) do
    search_string = Search.input_to_wildcard_string(initial_path.input, mode)

    base_items =
      from(
        [location: location] in base_query_for_description_and_location(),
        where: location.item_id in subquery(base_query_for_all_area_item_ids(area_id))
      )
      |> modify_query_search_descriptions(search_string)
      |> Repo.all()

    search_for_child(initial_path, base_items, path, thing, mode, thing_is_immediate_child)
  end

  defp search_for_child(
         parent_node,
         parent_search_results,
         path,
         thing,
         mode,
         thing_is_immediate_child
       ) do
    # if parent node doesn't specify which result, can use all of them and not have to iterate through each one on this round.
    case parent_search_results do
      # Player did not try and specify anything at this layer so go with all results
      matches when matches != [] and parent_node.which == 0 ->
        # if not another layer then grab thing and take the results from that and return them
        if path == [] do
          search_for_child_thing(matches, thing, mode, thing_is_immediate_child)
        else
          # if there is another layer recurse
          # search for children and pass results through
          search_for_child_next_path_step(
            matches,
            path,
            thing,
            mode,
            thing_is_immediate_child
          )
        end

      # There are possibly multiple matches, but the player might also have specified a specific item
      matches when matches != [] and parent_node.which > 0 ->
        # if a parent was specified, then all the results need to be grouped by their parent first (all root items equal parent?),
        # then all of those groups need to be filtered based on which selection to reflect searching entirely different containers.
        # This will let results and container chains to fall out of the results until there is a final set of results

        # and then once all those results have been filtered and gathered back up into a single result set, check to see if there
        # is still a further path and if so begin the search process again and recurse
        # if there is no further path then search for thing relative to matches

        filtered_matches =
          matches
          |> Repo.preload([:location])
          |> Enum.group_by(fn item ->
            cond do
              item.location.relative_to_item -> item.location.relative_item_id
              item.location.held_in_hand -> "#{item.location.character_id}:hand"
              item.location.worn_on_character -> item.location.character_id
              item.location.on_ground -> item.location.area_id
            end
          end)
          |> Enum.flat_map(fn {_parent, children} ->
            Enum.at(children, parent_node.which - 1, []) |> List.wrap()
          end)

        if path == [] do
          search_for_child_thing(filtered_matches, thing, mode, thing_is_immediate_child)
        else
          # if there is another layer recurse
          # search for children and pass results through
          search_for_child_next_path_step(
            filtered_matches,
            path,
            thing,
            mode,
            thing_is_immediate_child
          )
        end

      # No results were found so just return empty results
      [] ->
        []
    end
  end

  defp search_for_child_thing(parents, thing, mode, thing_is_immediate_child) do
    search_string = Search.input_to_wildcard_string(thing.input, mode)

    # search for thing relative to matches
    parent_ids = Enum.map(parents, & &1.id)

    query =
      if thing_is_immediate_child do
        immediate_children_with_relationship_query(parent_ids, thing.where)
        |> modify_query_select_id()
      else
        immediate_children_with_relationship_and_all_nested_child_ids_query(
          parent_ids,
          thing.where
        )
      end

    from(
      [location: location] in base_query_for_description_and_location(),
      where: location.item_id in subquery(query),
      order_by: [desc: location.moved_at]
    )
    |> modify_query_search_descriptions(search_string)
    |> Repo.all()
    |> Item.preload()
    |> ItemUtil.sort_items(true)
  end

  defp search_for_child_next_path_step(
         parents,
         path,
         thing,
         mode,
         thing_is_immediate_child
       ) do
    [next_path_step | rest_of_path] = path
    search_string = Search.input_to_wildcard_string(next_path_step.input, mode)
    parent_ids = Enum.map(parents, & &1.id)

    results =
      from(
        [location: location] in base_query_for_description_and_location(),
        where:
          location.item_id in subquery(
            immediate_children_with_relationship_and_all_nested_child_ids_query(
              parent_ids,
              next_path_step.where
            )
          ),
        order_by: [desc: location.moved_at]
      )
      |> modify_query_search_descriptions(search_string)
      |> Repo.all()

    search_for_child(
      next_path_step,
      results,
      rest_of_path,
      thing,
      mode,
      thing_is_immediate_child
    )
  end

  @doc """
  Items on ground are searched for a match.
  """
  def search_on_ground(area_id, search_string) do
    base_on_ground_query(area_id)
    |> modify_query_search_descriptions(search_string)
    |> Repo.all()
    |> Item.preload()
    |> ItemUtil.sort_items(true)
  end

  @doc """
  Items on ground are searched for a match.
  """
  def search_furniture_on_ground(area_id, search_string) do
    base_on_ground_query(area_id)
    |> modify_query_search_descriptions(search_string)
    |> Repo.all()
    |> Item.preload()
    |> Enum.filter(& &1.flags.is_furniture)
    |> ItemUtil.sort_items(true)
  end

  defp base_on_ground_query(area_id) do
    from(
      [description: description, location: location] in base_query_for_description_and_location(),
      where: location.area_id == ^area_id and location.on_ground,
      order_by: [desc: location.moved_at]
    )
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
    |> ItemUtil.sort_items(true)
  end

  @doc """
  Only worn items are searched for a match.
  """
  @spec search_worn_inventory(String.t(), String.t()) :: [Mud.Engine.Item.t()]
  def search_worn_inventory(character_id, search_string) do
    base_worn_inventory_query(character_id)
    |> modify_query_search_descriptions(search_string)
    |> Repo.all()
    |> Item.preload()
    |> ItemUtil.sort_items(true)
  end

  @doc """
  All surfaces visible in an area and the root items on the ground are searched for a match.
  """
  @spec search_on_ground_and_on_visible_surfaces_in_area(String.t(), String.t()) :: [
          Mud.Engine.Item.t()
        ]
  def search_on_ground_and_on_visible_surfaces_in_area(area_id, search_string) do
    search_for_items_on_ground_and_on_visible_surfaces_in_area_query(area_id)
    |> modify_query_search_descriptions(search_string)
    |> Repo.all()
    |> Item.preload()
    |> ItemUtil.sort_items(true)
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
    |> ItemUtil.sort_items(true)
  end

  def immediate_children_with_relationship_query(ids, relationship) do
    from([item, location: location] in base_query_for_description_and_location(),
      where: item.id in subquery(child_ids_query(ids)) and location.relation == ^relationship
    )
  end

  def weight_of_immediate_children_with_relationship(ids, relationship) do
    from([item, location: location, physics: physics, flags: flags] in base_query(),
      where:
        item.id in subquery(child_ids_query(List.wrap(ids))) and
          location.relation == ^relationship and
          flags.has_physics
    )
    |> Repo.all()
    |> Repo.preload([:physics])
    |> Stream.map(& &1.physics)
    |> Stream.filter(&(&1 != nil))
    |> Enum.reduce(0, &(&1.weight + &2))
  end

  def count_of_immediate_children_with_relationship(ids, relationship) do
    from([item, location: location] in base_query(),
      where:
        item.id in subquery(child_ids_query(List.wrap(ids))) and
          location.relation == ^relationship,
      select: count(item.id)
    )
    |> Repo.one()
  end

  @spec count_worn_items_in_slot(String.t(), String.t()) :: integer
  @doc """
  Given a character and a slot to check, return the number of items currently worn on the character in that spot.
  """
  def count_worn_items_in_slot(character_id, slot) do
    from(
      [item, location: location, wearable: wearable] in base_query_for_description_and_location_and_wearable(),
      where:
        location.character_id == ^character_id and location.worn_on_character and
          wearable.slot == ^slot,
      select: count(item.id)
    )
    |> Repo.one!()
  end

  #
  #
  # Helper/Internal Functions
  #
  #

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

  defp base_query_for_all_area_item_ids(area_id) do
    base_query_for_all_area_items(area_id)
    |> modify_query_select_id()
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

  defp search_for_items_on_ground_and_on_visible_surfaces_in_area_query(area_id) do
    from(
      [location: location] in base_query_for_description_and_location(),
      where:
        location.item_id in subquery(base_query_for_items_on_ground_ids(area_id)) or
          location.item_id in subquery(
            base_query_for_all_children_on_surfaces_in_area_ids(area_id)
          ),
      order_by: [desc: location.moved_at]
    )
  end

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

  defp base_worn_inventory_query(character_id) do
    from(
      [location: location] in base_query_for_description_and_location(),
      where: location.worn_on_character and location.character_id == ^character_id,
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

  defp base_query_for_description_and_location_and_wearable() do
    from(
      item in Mud.Engine.Item,
      left_join: location in assoc(item, :location),
      as: :location,
      left_join: description in assoc(item, :description),
      as: :description,
      left_join: wearable in assoc(item, :wearable),
      as: :wearable
    )
  end

  defp base_query_for_description_and_location_and_flags() do
    from(
      item in Mud.Engine.Item,
      left_join: location in assoc(item, :location),
      as: :location,
      left_join: description in assoc(item, :description),
      as: :description,
      left_join: flags in assoc(item, :flags),
      as: :flags
    )
  end

  defp base_query_for_all_inventory_ids(character_id) do
    base_query_for_all_inventory(character_id)
    |> modify_query_select_id()
  end

  # All queries which need to check item descriptions should go through this modifier function
  # It checks short and long descriptions as well as enforcing that at least one of the "words"
  # entered matches, via a fuzzy regex, the key for an item to help against false positives.
  defp modify_query_search_descriptions(query, search_string) do
    key_string =
      String.split(search_string, "%", trim: true)
      |> Stream.map(&".*#{&1}.*")
      |> Enum.join("|")

    key_regex = "^(#{key_string})$"

    from(
      [description: description] in query,
      where:
        like(description.short, ^search_string) and
          fragment("? ~* ?", description.key, ^key_regex)
    )
  end

  defp immediate_children_with_relationship_and_all_nested_child_ids_query(ids, relationship) do
    children_ids_query =
      immediate_children_with_relationship_query(ids, relationship)
      |> modify_query_select_id()

    from([item, location: location] in base_query_for_description_and_location(),
      where:
        item.id in subquery(modify_query_select_id(recursive_child_query(children_ids_query)))
    )
    |> modify_query_select_id()
  end

  defp modify_query_select_id(query) do
    from([item] in query, select: item.id)
  end

  defp base_query_for_worn_and_held_inventory_ids(character_id) do
    base_query_for_worn_and_held_inventory(character_id)
    |> modify_query_select_id()
  end

  defp base_query_for_worn_and_held_inventory(character_id) do
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
    from([location: location] in base_query_for_description_and_location_and_flags(),
      where:
        location.item_id in subquery(
          modify_query_select_id(
            recursive_surface_child_query(base_query_for_items_on_ground_ids(area_id))
          )
        )
    )
    |> modify_query_select_id()
  end

  defp base_query_for_all_inventory(character_id) do
    recursive_child_query(base_query_for_worn_and_held_inventory_ids(character_id))
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

    recursive_query =
      {"location_tree", Location}
      |> recursive_ctes(true)
      |> with_cte("location_tree", as: ^item_tree_query)
      |> select([location], location.item_id)

    from([location: location] in base_query_for_description_and_location(),
      where: location.item_id in subquery(recursive_query)
    )
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

    recursive_query =
      {"location_tree", Location}
      |> recursive_ctes(true)
      |> with_cte("location_tree", as: ^item_tree_query)
      |> select([location], location.item_id)

    from([location: location] in base_query_for_description_and_location(),
      where: location.item_id in subquery(recursive_query)
    )
  end

  def base_query() do
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
