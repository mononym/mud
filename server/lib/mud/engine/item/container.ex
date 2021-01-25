defmodule Mud.Engine.Item.Container do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  require Logger

  @type id :: String.t()

  @derive {Jason.Encoder,
           only: [
             :id,
             :item_id,
             :capacity,
             :height,
             :length,
             :locked,
             :open,
             :width
           ]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "item_containers" do
    belongs_to(:item, Mud.Engine.Item, type: :binary_id)
    field(:capacity, :integer, default: 1)
    field(:height, :integer, default: 1)
    field(:length, :integer, default: 1)
    field(:locked, :boolean, default: false)
    field(:open, :boolean, default: true)
    field(:width, :integer, default: 1)
  end

  @doc false
  def changeset(container, attrs) do
    container
    |> change()
    |> cast(attrs, [
      :item_id,
      :capacity,
      :height,
      :length,
      :locked,
      :open,
      :width
    ])
    |> foreign_key_constraint(:item_id)
  end

  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> changeset(Map.put(attrs, :moved_at, DateTime.utc_now()))
    |> Repo.insert!()
  end

  def update!(container, attrs) do
    container
    |> changeset(attrs)
    |> Repo.update!()
  end

  def update(container, attrs) do
    container
    |> changeset(attrs)
    |> Repo.update()
  end

  @spec get!(id :: binary) :: %__MODULE__{}
  def get!(id) when is_binary(id) do
    from(
      container in __MODULE__,
      where: container.id == ^id
    )
    |> Repo.one!()
  end

  @spec get(id :: binary) :: nil | %__MODULE__{}
  def get(id) when is_binary(id) do
    from(
      container in __MODULE__,
      where: container.id == ^id
    )
    |> Repo.one()
  end
end
