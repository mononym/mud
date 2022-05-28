defmodule Mud.Engine.Shop.Product do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  require Logger

  @type id :: String.t()

  @derive {Jason.Encoder,
           only: [
             :id,
             :shop_id,
             :template_id,
             :description,
             :copper,
             :bronze,
             :silver,
             :gold
           ]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "shop_products" do
    belongs_to(:shop, Mud.Engine.Shop, type: :binary_id)
    belongs_to(:template, Mud.Engine.Template, type: :binary_id)
    field(:description, :string)
    field(:copper, :integer, default: 0)
    field(:bronze, :integer, default: 0)
    field(:silver, :integer, default: 0)
    field(:gold, :integer, default: 0)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> change()
    |> cast(attrs, [
      :shop_id,
      :template_id,
      :description,
      :copper,
      :bronze,
      :silver,
      :gold
    ])
    |> validate_required([:description, :shop_id, :template_id])
    |> foreign_key_constraint(:shop_id)
  end

  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def update!(product, attrs) do
    product
    |> changeset(attrs)
    |> Repo.update!()
  end

  def update(product, attrs) do
    product
    |> changeset(attrs)
    |> Repo.update()
  end

  @spec get!(id :: binary) :: %__MODULE__{}
  def get!(id) when is_binary(id) do
    from(
      product in __MODULE__,
      where: product.id == ^id
    )
    |> Repo.one!()
  end

  @spec get(id :: binary) :: nil | %__MODULE__{}
  def get(id) when is_binary(id) do
    from(
      product in __MODULE__,
      where: product.id == ^id
    )
    |> Repo.one()
  end

  @doc """
  Deletes a map.

  ## Examples

      iex> delete(product)
      {:ok, %Product{}}

      iex> delete(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%__MODULE__{} = map) do
    Repo.delete(map)
  end
end
