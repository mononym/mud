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
    field(:container_closeable, :boolean, default: false)
    field(:container_open, :boolean, default: true)
    field(:container_lockable, :boolean, default: false)
    field(:container_locked, :boolean, default: false)
    field(:container_length, :integer, default: 0)
    field(:container_width, :integer, default: 0)
    field(:container_height, :integer, default: 0)
    field(:container_capacity, :integer, default: 0)

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
    Logger.debug(inspect(items))
    ids = Enum.map(items, & &1.id)

    item_tree_initial_query =
      __MODULE__
      |> where([i], is_nil(i.container_id))
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
end
