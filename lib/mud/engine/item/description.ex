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
             :details,
             :key,
             :item_id
           ]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "item_descriptions" do
    belongs_to(:item, Mud.Engine.Item, type: :binary_id)
    field(:short, :string)
    field(:details, :string, default: "There is nothing unusual to see.")
    field(:key, :string)
  end

  @doc false
  def changeset(description, attrs) do
    description
    |> cast(attrs, [
      :item_id,
      :details,
      :short,
      :key
    ])
    |> foreign_key_constraint(:item_id)
  end

  def create(attrs \\ %{}) do
    Logger.debug("Creating item description with attrs: #{inspect(attrs)}")

    %__MODULE__{}
    |> changeset(attrs)
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
