defmodule Mud.Engine.Item.Coin do
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
             :count,
             :copper,
             :bronze,
             :silver,
             :gold
           ]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "item_coins" do
    belongs_to(:item, Mud.Engine.Item, type: :binary_id)
    field(:count, :integer)
    field(:copper, :boolean, default: false)
    field(:bronze, :boolean, default: false)
    field(:silver, :boolean, default: false)
    field(:gold, :boolean, default: false)
  end

  @doc false
  def changeset(coin, attrs) do
    coin
    |> change()
    |> cast(attrs, [
      :item_id,
      :count,
      :copper,
      :bronze,
      :silver,
      :gold
    ])
    |> foreign_key_constraint(:item_id)
  end

  def create(attrs \\ %{}) do
    Logger.debug("Creating item coin with attrs: #{inspect(attrs)}")

    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert!()
  end

  def update!(coin, attrs) do
    coin
    |> changeset(attrs)
    |> Repo.update!()
  end

  def update(coin, attrs) do
    coin
    |> changeset(attrs)
    |> Repo.update()
  end

  @spec get!(id :: binary) :: %__MODULE__{}
  def get!(id) when is_binary(id) do
    from(
      coin in __MODULE__,
      where: coin.id == ^id
    )
    |> Repo.one!()
  end

  @spec get(id :: binary) :: nil | %__MODULE__{}
  def get(id) when is_binary(id) do
    from(
      coin in __MODULE__,
      where: coin.id == ^id
    )
    |> Repo.one()
  end
end
