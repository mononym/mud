defmodule Mud.Engine.Map do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mud.Repo
  alias Mud.Engine.{Area, Link}
  import Ecto.Query

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
    Repo.all(
      from(
        map in __MODULE__,
        order_by: [desc: map.updated_at]
      )
    )
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
  Returns a list of areas that are all related to a specific map.

  This includes areas that are linked to the areas that actually belong to the map

  ## Examples

      iex> list_map_areas(42)
      %{internal: [%Map{}], external: [%Map{}], links: [%Link{}]}

  """
  def fetch_data(map_id) do
    internal_areas =
      Repo.all(
        from(
          area in Area,
          where: area.map_id == ^map_id
        )
      )

    internal_ids = Enum.map(internal_areas, & &1.id) |> IO.inspect()

    links =
      Repo.all(
        from(
          link in Link,
          where: link.to_id in ^internal_ids or link.from_id in ^internal_ids
        )
      )
      |> IO.inspect()

    external_ids =
      links
      |> Stream.flat_map(&[&1.to_id, &1.from_id])
      |> Stream.uniq()
      |> Enum.filter(&(&1 not in internal_ids))
      |> IO.inspect()

    external_areas =
      Repo.all(
        from(
          area in Area,
          where: area.id in ^external_ids
        )
      )

    grouped_links =
      Enum.group_by(links, fn link ->
        if link.to_id in internal_ids or link.from_id in internal_ids do
          :internal
        else
          :external
        end
      end)

    %{
      external_areas: external_areas,
      internal_areas: internal_areas,
      internal_links: Map.get(grouped_links, :internal, []),
      external_links: Map.get(grouped_links, :external, [])
    }
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
    |> cast(attrs, [
      :name,
      :description,
      :map_size,
      :grid_size,
      :max_zoom,
      :min_zoom,
      :default_zoom
    ])
    |> validate_required([
      :name,
      :description,
      :map_size,
      :grid_size,
      :max_zoom,
      :min_zoom,
      :default_zoom
    ])
  end
end
