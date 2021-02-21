defmodule Mud.Engine.Shop do
  use Mud.Schema
  import Ecto.Changeset
  alias Mud.Repo
  alias Mud.Engine.Shop.Product
  import Ecto.Query
  require Logger

  @derive {Jason.Encoder,
           only: [
             :id,
             :area_id,
             :name,
             :description,
             :products
           ]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "shops" do
    field(:name, :string)
    field(:description, :string)
    belongs_to(:area, Mud.Engine.Area, type: :binary_id)
    has_many(:products, Product)
  end

  @doc """
  Returns the list of areas.

  ## Examples

      iex> list_all()
      [%__MODULE__{}, ...]

  """
  @spec list_all() :: [%__MODULE__{}]
  def list_all do
    base_query_without_preload()
    |> Repo.all()
  end

  @doc """
  Returns the list of areas with populated product.

  ## Examples

      iex> list_all_with_products()
      [%__MODULE__{}, ...]

  """
  @spec list_all_with_products() :: [%__MODULE__{}]
  def list_all_with_products do
    base_query_with_preload()
    |> Repo.all()
  end

  @doc """
  Gets a single area.

  Raises `Ecto.NoResultsError` if the Area does not exist.

  ## Examples

      iex> get!("123")
      %__MODULE__{}

      iex> get!("456")w
      ** (Ecto.NoResultsError)

  """
  @spec get!(id :: String.t()) :: %__MODULE__{}
  def get!(id), do: Repo.get!(__MODULE__, id)

  @doc """
  Creates a area.

  ## Examples

      iex> create(%{field: value})
      {:ok, %__MODULE__{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create(attributes :: map()) :: {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a area.

  ## Examples

      iex> update(area, %{field: new_value})
      {:ok, %__MODULE__{}}

      iex> update(area, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update(area :: %__MODULE__{}, attributes :: map()) ::
          {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
  def update(area, attrs) do
    area
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a area.

  ## Examples

      iex> delete(area)
      {:ok, %__MODULE__{}}

      iex> delete(area)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete(area :: %__MODULE__{}) :: {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
  def delete(area) do
    Repo.delete(area)
  end

  #
  # Private Functions
  #

  @doc false
  @spec changeset(area :: %__MODULE__{}, attributes :: map()) :: %Ecto.Changeset{}
  defp changeset(area, attrs) do
    area
    |> cast(attrs, [
      :area_id,
      :name,
      :description
    ])
    |> validate_required([
      :name,
      :description
    ])
    |> foreign_key_constraint(:area_id)
  end

  #
  #
  # Area Queries for use internally and externally
  #
  #

  @doc """
  Basic query for finding shops. Nothing fancy, no preloads.
  """
  def base_shop_query do
    from(area in __MODULE__)
  end

  @doc """
  Extends `base_shop_query` by filtering out shops which don't exactly match an id
  """
  def shop_by_id_query(id) do
    from(shop in base_shop_query(),
      where: shop.id == ^id
    )
  end

  #
  #
  # Helper functions
  #
  #

  def base_query_without_preload() do
    from(
      shop in __MODULE__,
      left_join: product in assoc(shop, :products),
      as: :product
    )
  end

  def base_query_with_preload() do
    from(
      shop in __MODULE__,
      left_join: product in assoc(shop, :products),
      as: :product,
      preload: [
        products: product
      ]
    )
  end
end
