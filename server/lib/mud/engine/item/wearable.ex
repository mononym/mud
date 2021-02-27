defmodule Mud.Engine.Item.Wearable do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  require Logger

  @type id :: String.t()

  @derive {Jason.Encoder,
           only: [
             :id,
             :slot,
             :item_id
           ]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "item_wearables" do
    belongs_to(:item, Mud.Engine.Item, type: :binary_id)
    field(:slot, :string, required: true)
  end

  @doc false
  def changeset(slot, attrs) do
    slot
    |> change()
    |> cast(attrs, [
      :item_id,
      :slot
    ])
    |> foreign_key_constraint(:item_id)
  end

  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert!()
  end

  def update!(slot, attrs) do
    slot
    |> changeset(attrs)
    |> Repo.update!()
  end

  def update(slot, attrs) do
    slot
    |> changeset(attrs)
    |> Repo.update()
  end

  @spec get!(id :: binary) :: %__MODULE__{}
  def get!(id) when is_binary(id) do
    from(
      slot in __MODULE__,
      where: slot.id == ^id
    )
    |> Repo.one!()
  end

  @spec get(id :: binary) :: nil | %__MODULE__{}
  def get(id) when is_binary(id) do
    from(
      slot in __MODULE__,
      where: slot.id == ^id
    )
    |> Repo.one()
  end
end
