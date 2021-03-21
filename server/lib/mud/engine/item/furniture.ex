defmodule Mud.Engine.Item.Furniture do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  alias Mud.Engine.Character.Status
  require Logger

  @type id :: String.t()

  @derive {Jason.Encoder,
           only: [
             :id,
             :item_id
           ]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "item_furniture" do
    belongs_to(:item, Mud.Engine.Item, type: :binary_id)
  end

  @doc false
  def changeset(furniture, attrs) do
    furniture
    |> change()
    |> cast(attrs, [
      :item_id,
    ])
    |> foreign_key_constraint(:item_id)
  end

  def create(attrs \\ %{}) do
    Logger.debug("Creating item furniture with attrs: #{inspect(attrs)}")

    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert!()
  end

  def update!(furniture, attrs) do
    furniture
    |> changeset(attrs)
    |> Repo.update!()
  end

  def update(furniture, attrs) do
    furniture
    |> changeset(attrs)
    |> Repo.update()
  end

  @spec get!(id :: binary) :: %__MODULE__{}
  def get!(id) when is_binary(id) do
    from(
      furniture in __MODULE__,
      where: furniture.id == ^id
    )
    |> Repo.one!()
  end

  @spec get(id :: binary) :: nil | %__MODULE__{}
  def get(id) when is_binary(id) do
    from(
      furniture in __MODULE__,
      where: furniture.id == ^id
    )
    |> Repo.one()
  end
end
