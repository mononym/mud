defmodule Mud.Engine.Map do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mud.Repo
  alias Mud.Engine.Area
  import Ecto.Query

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "maps" do
    field(:description, :string)
    field(:name, :string)

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
    Repo.all(base_all_map_query())
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
  def get!(id), do: Repo.one!(base_single_map_query(id))

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
    result =
      map
      |> changeset(attrs)
      |> Repo.update()
      |> IO.inspect(label: "update")

    case result do
      {:ok, map} ->
        {:ok, Repo.preload(map, :areas)} |> IO.inspect()

      error ->
        error
    end
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
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end

  defp base_single_map_query(map_id) do
    from(
      map in __MODULE__,
      left_join: area in assoc(map, :areas),
      where: map.id == ^map_id,
      preload: [areas: area]
    )
  end

  defp base_all_map_query() do
    from(
      map in __MODULE__,
      left_join: area in assoc(map, :areas),
      preload: [areas: area]
    )
  end
end
