defmodule Mud.Engine.Item do
  @moduledoc """
  An Item is the building block of almost everything in the world.

  Containers, swords, coins, gems, scarves, furniture, houses (the outsides anyway), and more are all Items.
  """
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo

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
    field(:glance_description, :string, default: "item")
    field(:look_description, :string, default: "item")

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
      :glance_description,
      :look_description,
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
      :wearable_worn_by_id
    ])
    |> validate_required([
      :glance_description,
      :look_description
    ])
    |> foreign_key_constraint(:character_id)
    |> foreign_key_constraint(:area_id)
  end

  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert!()
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

  def describe_look(item, _looking_character) do
    item.look_description
  end

  def describe_glance(item, _looking_character) do
    item.glance_description
  end
end
