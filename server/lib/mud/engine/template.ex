defmodule Mud.Engine.Template do
  use Mud.Schema
  import Ecto.Changeset
  alias Mud.Repo
  import Ecto.Query
  require Logger

  @derive {Jason.Encoder,
           only: [
             :id,
             :name,
             :description,
             :template
           ]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "templates" do
    field(:name, :string)
    field(:description, :string)
    field(:template, :map)
  end

  @doc """
  Returns the list of areas.

  ## Examples

      iex> list_all()
      [%__MODULE__{}, ...]

  """
  @spec list_all() :: [%__MODULE__{}]
  def list_all do
    base_query()
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
    res =
      area
      |> changeset(attrs)
      |> Repo.update()

    case res do
      {:ok, template} ->
        {:ok, Repo.preload(template, [:products])}

      error ->
        error
    end
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
      :name,
      :description,
      :template
    ])
    |> validate_required([
      :name,
      :description,
      :template
    ])
    |> foreign_key_constraint(:area_id)
  end

  #
  #
  # Area Queries for use internally and externally
  #
  #

  @doc """
  Basic query for finding templates. Nothing fancy, no preloads.
  """
  def base_template_query do
    from(area in __MODULE__)
  end

  @doc """
  Extends `base_template_query` by filtering out templates which don't exactly match an id
  """
  def template_by_id_query(id) do
    from(template in base_template_query(),
      where: template.id == ^id
    )
  end

  #
  #
  # Helper functions
  #
  #

  def base_query() do
    from(template in __MODULE__)
  end
end
