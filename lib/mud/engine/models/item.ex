defmodule Mud.Engine.Model.Item do
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
    # What sorts of roles the item can take on, and it can take on more than one.
    # A chest might also serve as a seat, for example
    field(:is_furniture, :boolean, default: false)
    field(:is_scenery, :boolean, default: false)
    field(:is_container, :boolean, default: false)

    # The state of the item
    field(:is_hidden, :boolean, default: false)
    field(:count, :integer, default: 1)

    # How to describe the item
    field(:glance_description, :string, default: "item")
    field(:look_description, :string, default: "item")

    # belongs_to(:container, __MODULE__,
    #   type: :binary_id,
    #   foreign_key: :container_id
    # )

    belongs_to(:area, Mud.Engine.Model.Area,
      type: :binary_id,
      foreign_key: :area_id
    )

    belongs_to(:character, Mud.Engine.Model.Character,
      type: :binary_id,
      foreign_key: :character_id
    )
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [
      :area_id,
      # :container_id,
      :character_id,
      :is_hidden,
      :is_furniture,
      :is_scenery,
      :glance_description,
      :look_description,
      :count
    ])
    |> validate_required([
      :is_hidden,
      :is_furniture,
      :is_scenery,
      :glance_description,
      :look_description,
      :count
    ])
    |> foreign_key_constraint(:container_id)
    |> foreign_key_constraint(:character_id)
    |> foreign_key_constraint(:area_id)
  end

  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert!()
  end

  @spec get!(id :: binary) :: __MODULE__.t()
  def get!(id) when is_binary(id) do
    from(
      item in __MODULE__,
      where: item.id == ^id
    )
    |> Repo.one!()
  end

  @spec get(id :: binary) :: nil | __MODULE__.t()
  def get(id) when is_binary(id) do
    from(
      item in __MODULE__,
      where: item.id == ^id
    )
    |> Repo.one()
  end

  @spec list_in_area(id) :: [__MODULE__.t()]
  def list_in_area(area_id) do
    from(
      item in __MODULE__,
      where: item.area_id == ^area_id
    )
    |> Repo.all()
  end

  @spec list_furniture_in_area(id) :: [__MODULE__.t()]
  def list_furniture_in_area(area_id) do
    from(
      item in __MODULE__,
      where: item.area_id == ^area_id and item.is_furniture == true
    )
    |> Repo.all()
  end

  @spec list_visible_scenery_in_area(id) :: [__MODULE__.t()]
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
