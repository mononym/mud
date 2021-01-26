defmodule Mud.Engine.Item do
  @moduledoc """
  An Item is the building block of almost everything in the world.

  Containers, swords, coins, gems, scarves, furniture, houses (the outsides anyway), and more are all Items.
  """
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
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

  @spec get(id :: binary) :: nil | %__MODULE__{}
  def get(id) when is_binary(id) do
    from([item] in base_query_with_preload(),
      where: item.id == ^id
    )
    |> Repo.one()
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
    |> list_all_recursive_query()
    |> Repo.all()
  end

  def list_all_recursive_parents(items) do
    ids = items_to_ids(items)

    final_query =
      from(item in list_all_recursive_query(ids),
        where: item.id not in ^ids
      )

    Repo.all(final_query)
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
  Turn a list of items into a string like: a wooden spoon on a ovaled silver plate on a tall wooden counter, a silver fork on the ground
  """
  def items_to_short_desc_with_nested_location(items) do
    parents = list_all_recursive_parents(items)
    parent_index = Enum.reduce(parents, %{}, fn item, map -> Map.put(map, item.id, item) end)

    Enum.map(items, fn item ->
      build_parent_string(item, parent_index)
    end)
  end

  defp build_parent_string(item = %{container_id: d}, parent_index) do
    "#{item.description.short}, #{d}"
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

  defp base_query_with_preload() do
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

  defp list_all_recursive_query(ids) do
    item_tree_initial_query =
      Location
      |> where(
        [l],
        l.relative_item_id in ^ids or l.item_id in ^ids
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

  defp items_to_ids(items) do
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
