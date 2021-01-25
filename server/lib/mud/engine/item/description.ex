defmodule Mud.Engine.Item.Description do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  require Logger

  @type id :: String.t()

  @derive {Jason.Encoder,
           only: [
             :id,
             :short,
             :long,
             :key,
             :item_id
           ]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "item_descriptions" do
    belongs_to(:item, Mud.Engine.Item, type: :binary_id)
    field(:short, :string, required: true)
    field(:long, :string, required: true)
    field(:key, :string, required: true)
  end

  @doc false
  def changeset(description, attrs) do
    description
    |> change()
    |> cast(attrs, [
      :item_id,
      :long,
      :short,
      :key
    ])
    |> foreign_key_constraint(:item_id)
  end

  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> changeset(Map.put(attrs, :moved_at, DateTime.utc_now()))
    |> Repo.insert!()
  end

  def update!(description, attrs) do
    description
    |> changeset(attrs)
    |> Repo.update!()
  end

  def update(description, attrs) do
    description
    |> changeset(attrs)
    |> Repo.update()
  end

  @spec get!(id :: binary) :: %__MODULE__{}
  def get!(id) when is_binary(id) do
    from(
      description in __MODULE__,
      where: description.id == ^id
    )
    |> Repo.one!()
  end

  @spec get(id :: binary) :: nil | %__MODULE__{}
  def get(id) when is_binary(id) do
    from(
      description in __MODULE__,
      where: description.id == ^id
    )
    |> Repo.one()
  end
end
