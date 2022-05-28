defmodule Mud.Engine.Item.Physics do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  require Logger

  @type id :: String.t()

  @derive {Jason.Encoder,
           only: [
             :id,
             :length,
             :width,
             :height,
             :weight,
             :item_id
           ]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "item_physics" do
    belongs_to(:item, Mud.Engine.Item, type: :binary_id)
    field(:length, :integer, default: 1)
    field(:width, :integer, default: 1)
    field(:height, :integer, default: 1)
    field(:weight, :integer, default: 1)
  end

  @doc false
  def changeset(physics, attrs) do
    physics
    |> change()
    |> cast(attrs, [
      :item_id,
      :length,
      :width,
      :height,
      :weight
    ])
    |> foreign_key_constraint(:item_id)
  end

  def create(attrs \\ %{}) do
    Logger.debug("Creating item physics with attrs: #{inspect(attrs)}")

    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert!()
  end

  def update!(physics, attrs) do
    physics
    |> changeset(attrs)
    |> Repo.update!()
  end

  def update(physics, attrs) do
    physics
    |> changeset(attrs)
    |> Repo.update()
  end

  @spec get!(id :: binary) :: %__MODULE__{}
  def get!(id) when is_binary(id) do
    from(
      physics in __MODULE__,
      where: physics.id == ^id
    )
    |> Repo.one!()
  end

  @spec get(id :: binary) :: nil | %__MODULE__{}
  def get(id) when is_binary(id) do
    from(
      physics in __MODULE__,
      where: physics.id == ^id
    )
    |> Repo.one()
  end
end
