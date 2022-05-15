defmodule Mud.Engine.Item.Closable do
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
             :open
           ]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "item_closable" do
    belongs_to(:item, Mud.Engine.Item, type: :binary_id)
    field(:open, :boolean, default: true)
  end

  @doc false
  def changeset(closable, attrs) do
    closable
    |> change()
    |> cast(attrs, [
      :item_id,
      :open
    ])
    |> foreign_key_constraint(:item_id)
  end

  def create(attrs \\ %{}) do
    Logger.debug("Creating item closable with attrs: #{inspect(attrs)}")

    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert!()
  end

  def update!(closable, attrs) do
    closable
    |> changeset(attrs)
    |> Repo.update!()
  end

  def update(closable, attrs) do
    closable
    |> changeset(attrs)
    |> Repo.update()
  end

  @spec get!(id :: binary) :: %__MODULE__{}
  def get!(id) when is_binary(id) do
    from(
      closable in __MODULE__,
      where: closable.id == ^id
    )
    |> Repo.one!()
  end

  @spec get(id :: binary) :: nil | %__MODULE__{}
  def get(id) when is_binary(id) do
    from(
      closable in __MODULE__,
      where: closable.id == ^id
    )
    |> Repo.one()
  end
end
