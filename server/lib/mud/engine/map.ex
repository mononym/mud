defmodule Mud.Engine.Map do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mud.Repo
  alias Mud.Engine.Area

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "maps" do
    field(:description, :string)
    field(:name, :string)
    field(:map_size, :integer)
    field(:grid_size, :integer)
    field(:max_zoom, :integer)
    field(:min_zoom, :integer)
    field(:default_zoom, :integer)

    has_many(:areas, Area)

    timestamps()
  end

  @doc """
  Returns the list of maps.

  ## Examples

  iex> list_all()
  [%Map{}, ...]

  """
  @spec list_all :: [%__MODULE__{}]
  def list_all do
    Repo.all(__MODULE__)
  end

  @doc """
  Gets a single map.

  Raises `Ecto.NoResultsError` if the Map does not exist.

  ## Examples

      iex> get!("42")
      %Map{}

      iex> get!("24")
      ** (Ecto.NoResultsError)

  """
  def get!(id), do: Repo.get!(__MODULE__, id)

  @doc """
  Creates a map.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Map{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    result =
      %__MODULE__{}
      |> changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, map} ->
        {:ok, Repo.preload(map, :areas)}

      error ->
        error
    end
  end

  @doc """
  Updates a map.

  ## Examples

      iex> update(map, %{field: new_value})
      {:ok, %Map{}}

      iex> update(map, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%__MODULE__{} = map, attrs) do
      map
      |> changeset(attrs)
      |> Repo.update()
  end

  @doc """
  Deletes a map.

  ## Examples

      iex> delete(map)
      {:ok, %Map{}}

      iex> delete(map)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%__MODULE__{} = map) do
    Repo.delete(map)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking map changes.

  ## Examples

      iex> changeset(map)
      %Ecto.Changeset{data: %Map{}}

  """
  def changeset(%__MODULE__{} = map, attrs \\ %{}) do
    map
    |> cast(attrs, [:name, :description, :map_size, :grid_size, :max_zoom, :min_zoom, :default_zoom])
    |> validate_required([:name, :description, :map_size, :grid_size, :max_zoom, :min_zoom, :default_zoom])
  end
end