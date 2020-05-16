defmodule Mud.Engine.Model.Item do
  @moduledoc """
  An Item is the building block of almost everything in the world.

  Containers, swords, coins, gems, scarves, furniture, houses (the outsides anyway), and more are all Items.
  """
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "items" do
    # What sorts of roles the item can take on, and it can take on more than one.
    # A chest might also serve as a seat, for example
    field(:is_furniture, :boolean, default: false)
    field(:is_scenery, :boolean, default: false)
    field(:is_container, :boolean, default: false)
    field(:count, :integer, default: 1)
    field(:glance_description, :string, default: "item")
    field(:look_description, :string, default: "item")

    belongs_to(:container, __MODULE__,
      type: :binary_id,
      foreign_key: :container_id
    )

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
  def changeset(description, attrs) do
    description
    |> cast(attrs, [
      :object_id,
      :is_furniture,
      :is_scenery,
      :glance_description,
      :look_description,
      :count
    ])
    |> validate_required([
      :object_id,
      :is_furniture,
      :is_scenery,
      :glance_description,
      :look_description,
      :count
    ])
    |> foreign_key_constraint(:object_id)
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

  def list_in_area(area_id) do
    from(
      item in __MODULE__,
      where: item.area_id == ^area_id
    )
    |> Repo.all()
  end
end
