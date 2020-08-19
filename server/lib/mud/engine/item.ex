defmodule Mud.Engine.Item do
  @moduledoc """
  An Item is the building block of almost everything in the world.

  Containers, swords, coins, gems, scarves, furniture, houses (the outsides anyway), and more are all Items.
  """
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  require Logger

  @type id :: String.t()

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "items" do
    ##
    #
    # Common Fields
    #
    ##

    belongs_to(:area, Mud.Engine.Area, type: :binary_id)

    timestamps()

    # The state of the item
    field(:is_hidden, :boolean, default: false)

    # How to describe the item
    field(:short_description, :string, default: "item")
    field(:long_description, :string, default: "item")

    # How to display the item in the client
    field(:icon, :string, default: "fas fa-question")

    ##
    #
    # Container Component
    #
    ##

    field(:is_container, :boolean, default: false)
    field(:container_capacity, :integer, default: 0)
    field(:container_closeable, :boolean, default: false)
    field(:container_height, :integer, default: 0)
    field(:container_length, :integer, default: 0)
    field(:container_lockable, :boolean, default: false)
    field(:container_locked, :boolean, default: false)
    field(:container_open, :boolean, default: true)
    field(:container_primary, :boolean, default: false)
    field(:container_width, :integer, default: 0)

    has_many(:container_items, __MODULE__, foreign_key: :container_id)
    belongs_to(:container, __MODULE__, type: :binary_id)

    ##
    #
    # Furniture Component
    #
    ##

    field(:is_furniture, :boolean, default: false)

    ##
    #
    # Scenery Component
    #
    ##

    field(:is_scenery, :boolean, default: false)

    ##
    #
    # Wearable Component
    #
    ##

    field(:is_wearable, :boolean, default: false)
    field(:wearable_is_worn, :boolean, default: false)
    field(:wearable_location, :string)
    belongs_to(:wearable_worn_by, Mud.Engine.Character, type: :binary_id)

    ##
    #
    # Holdable Component
    #
    ##

    field(:is_holdable, :boolean, default: false)
    field(:holdable_is_held, :boolean, default: false)
    field(:holdable_hand, :string)
    belongs_to(:holdable_held_by, Mud.Engine.Character, type: :binary_id)

    ##
    #
    # Physical Component: The item has a physical presence in the world that needs describing such as dimensions, weight, the the like
    #
    ##

    field(:is_physical, :boolean, default: false)
    field(:physical_length, :integer, default: 1)
    field(:physical_height, :integer, default: 1)
    field(:physical_width, :integer, default: 1)
    field(:physical_weight, :integer, default: 1)
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> change()
    |> cast(attrs, [
      :area_id,
      :is_hidden,
      :is_furniture,
      :is_scenery,
      :short_description,
      :long_description,
      :container_id,
      :is_container,
      :container_closeable,
      :container_open,
      :container_lockable,
      :container_locked,
      :container_length,
      :container_width,
      :container_height,
      :container_capacity,
      :container_primary,
      :is_wearable,
      :wearable_is_worn,
      :wearable_location,
      :wearable_worn_by_id,
      :is_holdable,
      :holdable_is_held,
      :holdable_hand,
      :holdable_held_by_id,
      :icon
    ])
    |> foreign_key_constraint(:character_id)
    |> foreign_key_constraint(:area_id)
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
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert!()
  end

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

    item
  end

  def update!(item, attrs) do
    item
    |> changeset(attrs)
    |> Repo.update!()
  end

  def update(item, attrs) do
    item
    |> changeset(attrs)
    |> Repo.update()
  end

  @spec get!(id :: binary) :: %__MODULE__{}
  def get!(id) when is_binary(id) do
    from(
      item in __MODULE__,
      where: item.id == ^id
    )
    |> Repo.one!()
  end

  @spec get(id :: binary) :: nil | %__MODULE__{}
  def get(id) when is_binary(id) do
    from(
      item in __MODULE__,
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

  def list_all_recursive([]) do
    []
  end

  def list_all_recursive(items) do
    Logger.debug(inspect(items), label: :list_all_recursive)
    ids = Enum.map(List.wrap(items), & &1.id)

    item_tree_initial_query =
      __MODULE__
      |> where([i], i.id in ^ids)

    item_tree_recursion_query =
      __MODULE__
      |> join(:inner, [i], it in "item_tree", on: i.container_id == it.id)

    item_tree_query =
      item_tree_initial_query
      |> union_all(^item_tree_recursion_query)

    final_query =
      {"item_tree", __MODULE__}
      |> recursive_ctes(true)
      |> with_cte("item_tree", as: ^item_tree_query)

    Repo.all(final_query)
  end

  def list_all_recursive_parents(items) do
    ids =
      items
      |> List.wrap()
      |> Enum.map(
        &if is_struct(&1) do
          &1.id
        else
          &1
        end
      )

    Logger.debug(inspect(ids))

    item_tree_initial_query =
      __MODULE__
      |> where([i], i.id in ^ids)

    item_tree_recursion_query =
      __MODULE__
      |> join(:inner, [i], it in "item_tree", on: i.id == it.container_id)

    item_tree_query =
      item_tree_initial_query
      |> union_all(^item_tree_recursion_query)

    final_query =
      {"item_tree", __MODULE__}
      |> recursive_ctes(true)
      |> with_cte("item_tree", as: ^item_tree_query)

    Repo.all(final_query)
  end

  @spec list_in_area(id) :: [%__MODULE__{}]
  def list_in_area(area_id) do
    from(
      item in __MODULE__,
      where: item.area_id == ^area_id
    )
    |> Repo.all()
  end

  @spec list_furniture_in_area(id) :: [%__MODULE__{}]
  def list_furniture_in_area(area_id) do
    from(
      item in __MODULE__,
      where: item.area_id == ^area_id and item.is_furniture == true
    )
    |> Repo.all()
  end

  @spec list_visible_scenery_in_area(id) :: [%__MODULE__{}]
  def list_visible_scenery_in_area(area_id) do
    from(
      item in __MODULE__,
      where: item.area_id == ^area_id and item.is_scenery == true and item.is_hidden == false
    )
    |> Repo.all()
  end

  @spec list_non_scenery_in_areas(Ecto.Multi.t(), atom(), String.t() | [String.t()]) ::
          Ecto.Multi.t()
  def list_non_scenery_in_areas(multi, name, area_ids) do
    Ecto.Multi.run(multi, name, fn repo, _changes ->
      area_ids = List.wrap(area_ids)

      from(
        item in __MODULE__,
        where: item.area_id in ^area_ids and item.is_scenery == false
      )
      |> repo.all()
      |> (&{:ok, &1}).()
    end)
  end

  @spec list_visible_scenery_in_area(Ecto.Multi.t(), atom(), String.t() | [String.t()]) ::
          Ecto.Multi.t()
  def list_visible_scenery_in_area(multi, name, area_ids) do
    Ecto.Multi.run(multi, name, fn repo, _changes ->
      area_ids = List.wrap(area_ids)

      from(
        item in __MODULE__,
        where: item.area_id in ^area_ids and item.is_scenery == true and item.is_hidden == false
      )
      |> repo.all()
      |> (&{:ok, &1}).()
    end)
  end

  @spec list_held_or_worn_items_and_children(String.t()) :: [%__MODULE__{}]
  def list_held_or_worn_items_and_children(character_id) do
    character_id
    |> held_or_worn_and_children_query()
    |> Repo.all()
  end

  @spec list_held_or_worn_items_and_children(Ecto.Multi.t(), atom(), String.t() | [String.t()]) ::
          Ecto.Multi.t()
  def list_held_or_worn_items_and_children(multi, name, character_id) do
    Ecto.Multi.run(multi, name, fn repo, _changes ->
      character_id
      |> held_or_worn_and_children_query()
      |> repo.all()
    end)
  end

  def list_contained_items(container_id) do
    from(
      item in __MODULE__,
      where: item.container_id == ^container_id
    )
    |> Repo.all()
  end

  def list_worn_containers(character_id) do
    from(
      item in __MODULE__,
      where: item.wearable_worn_by_id == ^character_id and item.is_container == true
    )
    |> Repo.all()
  end

  def list_worn_by(character_id) do
    from(
      item in __MODULE__,
      where: item.wearable_worn_by_id == ^character_id
    )
    |> Repo.all()
  end

  def list_held_by(character_id) do
    from(
      item in __MODULE__,
      where: item.holdable_held_by_id == ^character_id
    )
    |> Repo.all()
  end

  defp held_or_worn_and_children_query(character_id) do
    item_tree_initial_query =
      __MODULE__
      |> where(
        [i],
        i.wearable_worn_by_id == ^character_id or i.holdable_held_by_id == ^character_id
      )

    item_tree_recursion_query =
      __MODULE__
      |> join(:inner, [i], it in "item_tree", on: i.container_id == it.id)

    item_tree_query =
      item_tree_initial_query
      |> union_all(^item_tree_recursion_query)

    {"item_tree", __MODULE__}
    |> recursive_ctes(true)
    |> with_cte("item_tree", as: ^item_tree_query)
  end
end