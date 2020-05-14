defmodule Mud.Engine.Component.Area do
  use Mud.Schema
  import Ecto.Changeset
  alias Mud.Repo

  schema "areas" do
    field(:description, :string)
    field(:name, :string)
  end

  @doc """
  Returns the list of areas.

  ## Examples

      iex> list_all()
      [%__MODULE__{}, ...]

  """
  @spec list_all() :: [__MODULE__.t()]
  def list_all do
    Repo.all(__MODULE__)
  end

  @doc """
  Gets a single area.

  Raises `Ecto.NoResultsError` if the Area does not exist.

  ## Examples

      iex> get_area!("123")
      %__MODULE__{}

      iex> get_area!("456")
      ** (Ecto.NoResultsError)

  """
  @spec get_area!(id :: String.t()) :: __MODULE__.t()
  def get_area!(id), do: Repo.get!(__MODULE__, id)

  @doc """
  Creates a area.

  ## Examples

      iex> create_area(%{field: value})
      {:ok, %__MODULE__{}}

      iex> create_area(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_area(attributes :: map()) :: {:ok, __MODULE__.t()} | {:error, %Ecto.Changeset{}}
  def create_area(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a area.

  ## Examples

      iex> update_area(area, %{field: new_value})
      {:ok, %__MODULE__{}}

      iex> update_area(area, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_area(area :: __MODULE__.t(), attributes :: map()) ::
          {:ok, __MODULE__.t()} | {:error, %Ecto.Changeset{}}
  def update_area(area, attrs) do
    area
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a area.

  ## Examples

      iex> delete_area(area)
      {:ok, %__MODULE__{}}

      iex> delete_area(area)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_area(area :: __MODULE__.t()) :: {:ok, __MODULE__.t()} | {:error, %Ecto.Changeset{}}
  def delete_area(area) do
    Repo.delete(area)
  end

  #
  # Private Functions
  #

  @doc false
  @spec changeset(area :: __MODULE__.t(), attributes :: map()) :: %Ecto.Changeset{}
  defp changeset(area, attrs) do
    area
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
