defmodule Mud.Engine.Item do
  @moduledoc """
  An Item is the building block of almost everything in the world.

  Containers, swords, coins, gems, scarves, furniture, houses (the outsides anyway), and more are all Items.
  """
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  alias Mud.Engine.{Area, Character, Search}
  alias Mud.Engine.Item.{Flags, Location, Physics, Description, Container}
  require Logger

  @type id :: String.t()

  @derive Jason.Encoder
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "items" do
    ##
    #
    # Common Fields
    #
    ##
    has_one(:location, Location)
    has_one(:flags, Flags)
    has_one(:description, Description)
    has_one(:container, Container)
    has_one(:physics, Physics)

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> change()
    |> cast(attrs, [])
  end

  @topic inspect(__MODULE__)

  @doc """
  Subscribe to the PubSub topic for all Character events.
  """
  @spec subscribe :: {:ok, :subscribed}
  def subscribe do
    :ok = Phoenix.PubSub.subscribe(Mud.PubSub, @topic)
    {:ok, :subscribed}
  end

  @doc """
  Subscribe to the PubSub topic for all Character events related to a single Character.
  """
  @spec subscribe(String.t()) :: {:ok, :subscribed}
  def subscribe(item_id) when is_binary(item_id) do
    :ok = Phoenix.PubSub.subscribe(Mud.PubSub, @topic <> ":#{item_id}")
    {:ok, :subscribed}
  end

  def create(attrs \\ %{}) do
    Repo.transaction(fn ->
      item = insert_new()
      # result =
      #   %__MODULE__{}

      # case result do
      # {:ok, item} ->
      # Set up flags
      flags = Flags.create(Map.put(Map.get(attrs, :flags, %{}), :item_id, item.id))
      # Set up description
      description =
        Description.create(Map.put(Map.get(attrs, :description, %{}), :item_id, item.id))

      # Set up container
      container = Container.create(Map.put(Map.get(attrs, :container, %{}), :item_id, item.id))
      # Set up physics
      physics = Physics.create(Map.put(Map.get(attrs, :physics, %{}), :item_id, item.id))
      # Set up location
      location = Location.create(Map.put(Map.get(attrs, :location, %{}), :item_id, item.id))

      %{
        item
        | flags: flags,
          description: description,
          container: container,
          physics: physics,
          location: location
      }
    end)

    # {:ok, item}

    # error ->
    #   error
    # end
  end

  @spec update!(String.t(), map()) :: %__MODULE__{}
  def update!(item_id, attrs) when is_binary(item_id) do
    keywords =
      attrs
      |> Keyword.new()
      |> Keyword.put_new(:updated_at, Timex.now())

    item =
      from(item in __MODULE__, where: item.id == ^item_id, select: item)
      |> Repo.update_all(set: keywords)
      |> elem(1)
      |> List.first()
      |> Repo.preload(:location)

    item
  end

  def update!(item, attrs) do
    item
    |> changeset(attrs)
    |> Repo.update!()
    |> Repo.preload(:location)
  end

  def update(item, attrs) do
    result =
      item
      |> changeset(attrs)
      |> Repo.update()

    case result do
      {:ok, item} ->
        {:ok, Repo.preload(item, :location)}

      error ->
        error
    end
  end

  @spec get!(id :: binary) :: %__MODULE__{}
  def get!(id) when is_binary(id) do
    from([item] in base_query_with_preload(),
      where: item.id == ^id
    )
    |> Repo.one!()
  end

  @spec get(id :: binary) :: {:ok, %__MODULE__{}} | {:error, :not_found}
  def get(id) when is_binary(id) do
    from([item] in base_query_with_preload(),
      where: item.id == ^id
    )
    |> Repo.one()
    |> case do
      nil ->
        {:error, :not_found}

      item ->
        {:ok, item}
    end
  end

  def get_primary_container(character_id) when is_binary(character_id) do
    from(
      item in __MODULE__,
      where:
        item.wearable_worn_by_id == ^character_id and item.is_container and item.container_primary
    )
    |> Repo.one()
  end

  def get_primary_container(character) when is_struct(character),
    do: get_primary_container(character.id)

  def toggle_container_open(item_id) do
    from(item in __MODULE__,
      where: item.id == ^item_id,
      update: [set: [container_open: not item.container_open]],
      select: item
    )
    |> Repo.update_all([])
    |> elem(1)
    |> List.first()
  end

  @doc """
  Given one or more items, return them and all of their parents.
  """
  @spec list_all_recursive(%__MODULE__{} | [%__MODULE__{}] | String.t() | [String.t()]) :: [
          %__MODULE__{}
        ]
  def list_all_recursive([]) do
    []
  end

  def list_all_recursive(items) do
    items
    |> items_to_ids()
    |> list_all_recursive_parent_query(true)
    |> Repo.all()
  end

  def list_all_parents(items) do
    ids = items_to_ids(items)

    Repo.all(list_all_recursive_parent_query(ids, true))
  end

  @doc """
  List all items on the ground. Does not include scenery
  """
  @spec list_on_ground(id) :: [%__MODULE__{}]
  def list_on_ground(area_id) do
    from([location: location] in items_on_ground_query(area_id),
      order_by: location.moved_at
    )
    |> Repo.all()
  end

  @doc """
  List all items in an Area, those on the ground and scenery included.
  """
  @spec list_in_area(id) :: [%__MODULE__{}]
  def list_in_area(area_id) do
    from([location: location] in all_in_area_query(area_id),
      order_by: location.moved_at
    )
    |> Repo.all()
  end

  @doc """
  List all furniture in an Area.
  """
  @spec list_furniture_in_area(id) :: [%__MODULE__{}]
  def list_furniture_in_area(area_id) do
    from(
      item in __MODULE__,
      where: item.area_id == ^area_id and item.is_furniture == true,
      order_by: item.moved_at
    )
    |> Repo.all()
  end

  @spec list_visible_scenery_in_area(id) :: [%__MODULE__{}]
  def list_visible_scenery_in_area(area_id) do
    from(
      item in __MODULE__,
      where: item.area_id == ^area_id and item.is_scenery == true and item.is_hidden == false,
      order_by: item.moved_at
    )
    |> Repo.all()
  end

  @spec list_scenery_in_area(id) :: [%__MODULE__{}]
  def list_scenery_in_area(area_id) do
    from(
      item in scenery_in_area_query(area_id),
      order_by: item.moved_at
    )
    |> Repo.all()
  end

  @spec list_held_or_worn_items_and_children(String.t()) :: [%__MODULE__{}]
  def list_held_or_worn_items_and_children(character_id) do
    character_id
    |> held_or_worn_and_children_query()
    |> order_by([i], i.moved_at)
    |> Repo.all()
  end

  def list_contained_items(container_id) do
    from(
      item in __MODULE__,
      where: item.container_id == ^container_id,
      order_by: item.moved_at
    )
    |> Repo.all()
  end

  @doc """
  Turn a list of items strings like: [{item, "a wooden spoon on a ovaled silver plate on a tall wooden counter"}, {item2, "a silver fork on the ground"}]
  """
  def items_to_short_desc_with_nested_location(items) do
    items = List.wrap(items)
    parents = list_all_parents(items)
    parent_index = Enum.reduce(parents, %{}, fn item, map -> Map.put(map, item.id, item) end)

    Enum.map(items, fn item ->
      {item, build_parent_string(item, parent_index)}
    end)
  end

  defp build_parent_string(item, parent_index) do
    cond do
      item.location.relative_to_item ->
        "#{item.description.short} #{item.location.relation} #{
          build_parent_string(parent_index[item.location.relative_item_id], parent_index)
        }"

      item.flags.scenery ->
        item.description.short

      item.location.on_ground ->
        "#{item.description.short} on the ground"

      item.location.worn_on_character ->
        "#{item.description.short} which you are wearing"

      item.location.held_in_hand ->
        "#{item.description.short} which you are holding"
    end
  end

  @doc """
  Worn containers are searched for a match in the Repo using the search_string as part of a LIKE query.
  """
  def search_worn_containers(character_id, search_string) do
    from(
      [description: description, location: location, flags: flags] in base_query_with_preload(),
      where:
        location.character_id == ^character_id and location.worn_on_character and
          flags.container == true and flags.wearable and
          like(description.short, ^search_string),
      order_by: location.moved_at
    )
    |> Repo.all()
  end

  @doc """
  All inventory items are searched for a match in the Repo using the search_string as part of a LIKE query.
  """
  @spec search_inventory(String.t(), String.t()) :: [%__MODULE__{}]
  def search_inventory(character_id, search_string) do
    search_inventory_query(character_id, search_string)
    |> Repo.all()
  end

  @doc """
  Worn items are searched for a match in the Repo using the search_string as part of a LIKE query.
  """
  def search_worn_items(character_id, search_string) do
    from(
      [description: description, location: location, flags: flags] in base_query_with_preload(),
      where:
        location.character_id == ^character_id and location.worn_on_character and flags.wearable and
          like(description.short, ^search_string),
      order_by: location.moved_at
    )
    |> Repo.all()
  end

  @doc """
  """
  def search_relative_to_inventory(
        character_id,
        [initial_path | path],
        thing,
        mode
      ) do
    initial_query =
      specific_nested_item_inventory_initial_query(
        character_id,
        Search.input_to_wildcard_string(initial_path.input, mode)
      )

    build_and_execute_relative_query(initial_query, path, thing)
  end

  @doc """
  """
  def search_relative_to_item_on_ground_or_worn_or_held_items(
        area_id,
        character_id,
        [initial_path | path],
        thing,
        mode
      ) do
    initial_query =
      specific_nested_item_held_ground_worn_initial_query(
        character_id,
        area_id,
        Search.input_to_wildcard_string(initial_path.input, mode)
      )

    build_and_execute_relative_query(initial_query, path, thing)
  end

  defp build_and_execute_relative_query(initial_query, path, thing) do
    mostly_constructed_query = build_nested_relative_query(initial_query, path)

    final_query =
      specific_nested_item_top_level_query(
        mostly_constructed_query,
        Search.input_to_wildcard_string(thing.input),
        thing.where
      )

    Repo.all(final_query)
  end

  defp build_nested_relative_query(previous_query, []) do
    previous_query
  end

  defp build_nested_relative_query(previous_query, [current_path | path]) do
    current_query =
      specific_nested_item_mid_level_query(
        previous_query,
        Search.input_to_wildcard_string(current_path.input),
        current_path.where
      )

    build_nested_relative_query(current_query, path)
  end

  @doc """
  Items on ground are searched for a match in the Repo using the search_string as part of a LIKE query.
  """
  def search_on_ground(area_id, search_string) do
    from(
      [description: description, location: location] in base_query_with_preload(),
      where:
        location.area_id == ^area_id and location.on_ground and
          like(description.short, ^search_string),
      order_by: location.moved_at
    )
    |> Repo.all()
  end

  @doc """
  Items on ground are searched for a match in the Repo using the search_string as part of a LIKE query.
  """
  @spec search_on_ground_or_worn_items(String.t(), String.t(), String.t()) :: [Item.t()]
  def search_on_ground_or_worn_items(area_id, character_id, search_string) do
    from(
      [description: description, location: location, flags: flags] in base_query_with_preload(),
      where:
        (location.area_id == ^area_id and location.on_ground and
           like(description.short, ^search_string)) or
          (location.character_id == ^character_id and location.worn_on_character and
             flags.wearable and
             like(description.short, ^search_string)),
      order_by: location.moved_at,
      order_by: fragment("CASE i1.on_ground WHEN true THEN 0 ELSE 1 END")
    )
    |> Repo.all()
  end

  @doc """
  Items on ground are searched for a match in the Repo using the search_string as part of a LIKE query.
  """
  @spec search_on_ground_or_worn_or_held_items(String.t(), String.t(), String.t()) :: [Item.t()]
  def search_on_ground_or_worn_or_held_items(area_id, character_id, search_string) do
    from(
      [description: description, location: location, flags: flags] in base_query_with_preload(),
      where:
        (location.area_id == ^area_id and location.on_ground and
           like(description.short, ^search_string)) or
          (location.character_id == ^character_id and
             (location.worn_on_character or location.held_in_hand) and
             like(description.short, ^search_string)),
      order_by: location.moved_at,
      order_by:
        fragment(
          "CASE WHEN i1.on_ground THEN 0 WHEN i1.held_in_hand OR i1.worn_on_character THEN 1 ELSE 2 END"
        )
    )
    |> Repo.all()
  end

  @doc """
  Search items relative to other items
  """
  @spec search_relative_to_items([String.t()], String.t(), String.t()) :: [Item.t()]
  def search_relative_to_items(item_ids, relation, search_string) do
    from(
      [container: container, description: description, location: location, flags: flags] in base_query_with_preload(),
      where:
        location.relative_item_id in ^items_to_ids(item_ids) and location.relative_to_item and
          location.relation == ^relation and
          like(description.short, ^search_string),
      order_by: location.moved_at
    )
    |> Repo.all()
  end

  def list_worn_containers(character_id) do
    from(
      [description: description, location: location, flags: flags] in base_query_with_preload(),
      where:
        location.character_id == ^character_id and location.worn_on_character and
          flags.container == true and flags.wearable,
      order_by: location.moved_at
    )
    |> Repo.all()
  end

  @doc """
  Given an item, determines if any of the parents are held/worn by a character
  """
  def in_inventory?(item = %__MODULE__{}, character) do
    in_inventory?(item.id, character)
  end

  def in_inventory?(item, character = %Character{}) do
    in_inventory?(item, character.id)
  end

  def in_inventory?(item_id, character_id) do
    res =
      Repo.one(
        from([location: location] in base_query_without_preload(),
          where:
            location.item_id in subquery(recursive_parent_ids_query([item_id], true)) and
              (location.held_in_hand or location.worn_on_character) and
              location.character_id == ^character_id
        )
      )

    res != nil
  end

  @doc """
  Given an item, determines if any of the parents are held/worn by a character
  """
  def in_area?(item = %__MODULE__{}, area) do
    in_area?(item.id, area)
  end

  def in_area?(item, area = %Area{}) do
    in_area?(item, area.id)
  end

  def in_area?(item_id, area_id) do
    res =
      Repo.one(
        from([flags: flags, location: location] in base_query_without_preload(),
          where:
            location.item_id in subquery(recursive_parent_ids_query([item_id], true)) and
              location.on_ground and location.area_id == ^area_id
        )
      )

    res != nil
  end

  @doc """
  Checks all parents up to the root to ensure that they are open if they are containers.

  If the item is a root item itself, being held in the hand or worn or on the ground, `true` is returned.
  """
  def parent_containers_open?(%{
        location: %{
          on_ground: on_ground,
          held_in_hand: held_in_hand,
          worn_on_character: worn_on_character
        }
      })
      when on_ground or held_in_hand or worn_on_character do
    true
  end

  def parent_containers_open?(item = %__MODULE__{}) do
    from(container in Container,
      where: container.item_id in subquery(recursive_parent_ids_query(List.wrap(item.id))),
      select: fragment("bool_and(?)", container.open)
    )
    |> Repo.one!()
  end

  def list_worn_by(character_id) do
    from(
      item in __MODULE__,
      where: item.wearable_worn_by_id == ^character_id,
      order_by: item.moved_at
    )
    |> Repo.all()
  end

  def list_held_by(character_id) do
    from(
      item in __MODULE__,
      where: item.holdable_held_by_id == ^character_id,
      order_by: item.moved_at
    )
    |> Repo.all()
  end

  defp held_or_worn_and_children_query(character_id) do
    item_tree_initial_query =
      Location
      |> where(
        [l],
        l.character_id == ^character_id and (l.held_in_hand or l.worn_on_character)
      )

    item_tree_recursion_query =
      Location
      |> join(
        :inner,
        [location],
        lt in "location_tree",
        on:
          location.relative_item_id == lt.item_id and location.relative_to_item and
            location.relation == ^"in"
      )

    item_tree_query =
      item_tree_initial_query
      |> union_all(^item_tree_recursion_query)

    all_item_ids =
      {"location_tree", Location}
      |> recursive_ctes(true)
      |> with_cte("location_tree", as: ^item_tree_query)
      |> select([l], l.item_id)

    from(item in base_query_with_preload(), where: item.id in subquery(all_item_ids))
  end

  #
  #
  # Helper functions
  #
  #

  def base_query_without_preload() do
    from(
      item in __MODULE__,
      left_join: location in assoc(item, :location),
      as: :location,
      left_join: container in assoc(item, :container),
      as: :container,
      left_join: description in assoc(item, :description),
      as: :description,
      left_join: flags in assoc(item, :flags),
      as: :flags,
      left_join: physics in assoc(item, :physics),
      as: :physics
    )
  end

  def base_query_with_preload() do
    from(
      item in __MODULE__,
      left_join: location in assoc(item, :location),
      as: :location,
      left_join: container in assoc(item, :container),
      as: :container,
      left_join: description in assoc(item, :description),
      as: :description,
      left_join: flags in assoc(item, :flags),
      as: :flags,
      left_join: physics in assoc(item, :physics),
      as: :physics,
      preload: [
        container: container,
        description: description,
        flags: flags,
        location: location,
        physics: physics
      ]
    )
  end

  defp items_on_ground_query(area_id) do
    from(
      [item, location: location, flags: flags] in base_query_with_preload(),
      where: location.on_ground == true and location.area_id == ^area_id and not flags.scenery
    )
  end

  defp scenery_in_area_query(area_id) do
    from(
      [item, location: location, flags: flags] in base_query_with_preload(),
      where: location.on_ground == true and location.area_id == ^area_id and flags.scenery
    )
  end

  defp all_in_area_query(area_id) do
    from(
      [location: location] in base_query_with_preload(),
      where: location.area_id == ^area_id
    )
  end

  defp insert_new() do
    Repo.insert!(%__MODULE__{})
  end

  def list_all_recursive_parent_query(ids, include_self \\ false) do
    from(item in base_query_with_preload(),
      where: item.id in subquery(recursive_parent_ids_query(ids, include_self))
    )
  end

  def recursive_parent_ids_query(ids, include_self \\ false) do
    from(location in recursive_parent_query(ids, include_self), select: location.item_id)
  end

  def recursive_child_ids_query(ids, include_self \\ false) do
    from(location in recursive_child_query(ids, include_self), select: location.item_id)
  end

  defp specific_nested_item_held_ground_worn_initial_query(
         character_id,
         area_id,
         search_string
       ) do
    from(
      [item, description: description, location: location] in base_query_without_preload(),
      where:
        (((location.held_in_hand or location.worn_on_character) and
            location.character_id == ^character_id) or
           (location.on_ground and location.area_id == ^area_id)) and
          like(description.short, ^search_string),
      select: item.id
    )
  end

  def specific_nested_item_inventory_initial_query(
        character_id,
        search_string
      ) do
    from(
      [description: description, location: location] in base_query_without_preload(),
      where:
        description.item_id in subquery(base_query_for_all_inventory_ids(character_id)) and
          like(description.short, ^search_string),
      select: description.item_id
    )
  end

  def specific_nested_item_mid_level_query(
        previous_query,
        search_string,
        relation
      ) do
    from(
      [description: description, location: location] in base_query_without_preload(),
      where:
        location.relative_to_item and
          location.item_id in subquery(recursive_child_ids_query(previous_query, true)) and
          location.relation == ^relation and
          like(description.short, ^search_string),
      select: description.item_id
    )
  end

  def specific_nested_item_top_level_query(
        previous_query,
        search_string,
        relation
      ) do
    from(
      [description: description, location: location] in base_query_with_preload(),
      where:
        location.relative_to_item and
          location.item_id in subquery(recursive_child_ids_query(previous_query, true)) and
          location.relation == ^relation and
          like(description.short, ^search_string)
    )
  end

  def recursive_parent_query(maybe_subqry, include_self) do
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
        on: lt.relative_item_id == location.item_id
      )

    item_tree_query =
      item_tree_initial_query
      |> union_all(^item_tree_recursion_query)

    final_query =
      {"location_tree", Location}
      |> recursive_ctes(true)
      |> with_cte("location_tree", as: ^item_tree_query)

    if include_self do
      final_query
    else
      if is_list(maybe_subqry) do
        from(item in final_query, where: item.item_id not in ^maybe_subqry)
      else
        from(item in final_query, where: item.item_id not in subquery(maybe_subqry))
      end
    end
  end

  defp recursive_child_query(maybe_subqry, include_self) do
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

    final_query =
      {"location_tree", Location}
      |> recursive_ctes(true)
      |> with_cte("location_tree", as: ^item_tree_query)

    if include_self do
      final_query
    else
      if is_list(maybe_subqry) do
        from(item in final_query, where: item.item_id not in ^maybe_subqry)
      else
        from(item in final_query, where: item.item_id not in subquery(maybe_subqry))
      end
    end
  end

  defp modify_query_select_id(query) do
    from(item in query, select: item.id)
  end

  defp modify_query_select_item_id(query) do
    from(location in query, select: location.item_id)
  end

  def base_query_for_all_inventory_ids(character_id) do
    base_query_for_all_inventory(character_id)
    |> modify_query_select_item_id()
  end

  def base_query_for_all_inventory(character_id) do
    recursive_child_query(base_query_for_root_inventory_ids(character_id), true)
  end

  def base_query_for_root_inventory_ids(character_id) do
    base_query_for_root_inventory(character_id)
    |> modify_query_select_id()
  end

  def base_query_for_root_inventory(character_id) do
    from(
      [location: location] in base_query_without_preload(),
      where:
        (location.held_in_hand or location.worn_on_character) and
          location.character_id == ^character_id
    )
  end

  def search_inventory_query(character_id, search_string) do
    from(
      [description: description, location: location] in base_query_with_preload(),
      where:
        description.item_id in subquery(base_query_for_all_inventory_ids(character_id)) and
          like(description.short, ^search_string),
      order_by: [desc: location.moved_at]
    )
  end

  def items_to_ids(items) do
    items
    |> List.wrap()
    |> Enum.map(
      &if is_struct(&1) do
        &1.id
      else
        &1
      end
    )
  end
end
