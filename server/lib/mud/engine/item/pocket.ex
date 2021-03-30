defmodule Mud.Engine.Item.Pocket do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  alias Mud.Engine.ItemSearch
  require Logger

  @type id :: String.t()

  @derive {Jason.Encoder,
           only: [
             :id,
             :item_id,
             :capacity,
             :height,
             :item_limit,
             :length,
             :width
           ]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "item_pockets" do
    belongs_to(:item, Mud.Engine.Item, type: :binary_id)
    field(:capacity, :integer, default: 0)
    field(:height, :integer, default: 0)
    field(:length, :integer, default: 0)
    field(:width, :integer, default: 0)
    field(:item_limit, :integer, default: 0)
  end

  @doc false
  def changeset(pocket, attrs) do
    pocket
    |> change()
    |> cast(attrs, [
      :item_id,
      :capacity,
      :height,
      :item_limit,
      :length,
      :width
    ])
    |> foreign_key_constraint(:item_id)
  end

  def create(attrs \\ %{}) do
    Logger.debug("Creating item pocket with attrs: #{inspect(attrs)}")

    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert!()
  end

  def update!(pocket, attrs) do
    pocket
    |> changeset(attrs)
    |> Repo.update!()
  end

  def update(pocket, attrs) do
    pocket
    |> changeset(attrs)
    |> Repo.update()
  end

  @spec get!(id :: binary) :: %__MODULE__{}
  def get!(id) when is_binary(id) do
    from(
      pocket in __MODULE__,
      where: pocket.id == ^id
    )
    |> Repo.one!()
  end

  @spec get(id :: binary) :: nil | %__MODULE__{}
  def get(id) when is_binary(id) do
    from(
      pocket in __MODULE__,
      where: pocket.id == ^id
    )
    |> Repo.one()
  end
end
