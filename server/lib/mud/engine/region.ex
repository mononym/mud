defmodule Mud.Engine.Region do
  @moduledoc """
  Regions organize Areas into groups of associated places.
  """
  use Mud.Schema
  import Ecto.Changeset
  alias Mud.Repo
  alias Mud.Engine.{Area, Link}
  import Ecto.Query

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "regions" do
    field(:name, :string)

    has_many(:areas, Area)

    timestamps()
  end

  @doc """
  Returns the list of regions.

  ## Examples

      iex> list_all()
      [%__MODULE__{}, ...]

  """
  @spec list_all() :: [%__MODULE__{}]
  def list_all do
    Repo.all(__MODULE__)
  end

  def list_area_and_link_ids(region_id) do
    area_ids =
      Repo.all(
        from(
          area in Area,
          where: area.region_id == ^region_id,
          select: area.id
        )
      )

    link_ids =
      Repo.all(
        from(
          link in Link,
          where: link.to_id in ^area_ids or link.from_id in ^area_ids,
          select: {link.id, link.from_id, link.to_id}
        )
      )

    %{area_ids: area_ids, link_ids: link_ids}
  end

  @doc """
  Gets a single region.

  Raises `Ecto.NoResultsError` if the Region does not exist.

  ## Examples

      iex> get_region!("123")
      %__MODULE__{}

      iex> get_region!("456")w
      ** (Ecto.NoResultsError)

  """
  @spec get_region!(id :: String.t()) :: %__MODULE__{}
  def get_region!(id), do: Repo.get!(__MODULE__, id)

  @spec get_region!(Ecto.Multi.t(), atom(), String.t()) :: Ecto.Multi.t()
  def get_region!(multi, name, region_id) do
    Ecto.Multi.run(multi, name, fn repo, _changes ->
      {:ok, repo.get!(__MODULE__, region_id)}
    end)
  end

  @spec get_from_area!(area_id :: String.t()) :: %__MODULE__{}
  def get_from_area!(area_id) do
    Repo.one!(
      from(
        region in __MODULE__,
        join: area in Area,
        on: area.region_id == region.id,
        where: area.id == ^area_id
      )
    )
  end

  @doc """
  Creates a region.

  ## Examples

      iex> create_region(%{field: value})
      {:ok, %__MODULE__{}}

      iex> create_region(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_region(attributes :: map()) :: {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
  def create_region(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a region.

  ## Examples

      iex> update_region(region, %{field: new_value})
      {:ok, %__MODULE__{}}

      iex> update_region(region, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_region(region :: %__MODULE__{}, attributes :: map()) ::
          {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
  def update_region(region, attrs) do
    region
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a region.

  ## Examples

      iex> delete_region(region)
      {:ok, %__MODULE__{}}

      iex> delete_region(region)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_region(region :: %__MODULE__{}) ::
          {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
  def delete_region(region) do
    Repo.delete(region)
  end

  #
  # Private Functions
  #

  @doc false
  @spec changeset(region :: %__MODULE__{}, attributes :: map()) :: %Ecto.Changeset{}
  defp changeset(region, attrs) do
    region
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
