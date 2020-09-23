defmodule Mud.Engine.Instance do
  use Mud.Schema
  import Ecto.Changeset
  alias Mud.Repo
  alias Mud.DataType.NameSlug

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "instances" do
    field(:description, :string)
    field(:name, :string)
    field(:slug, NameSlug.Type)

    timestamps()
  end

  @doc """
  Returns the list of instances.

  ## Examples

      iex> list_all()
      [%__MODULE__{}, ...]

  """
  @spec list_all() :: [%__MODULE__{}]
  def list_all do
    Repo.all(__MODULE__)
  end

  @doc """
  Gets a single instance.

  Raises `Ecto.NoResultsError` if the Area does not exist.

  ## Examples

      iex> get_instance!("123")
      %__MODULE__{}

      iex> get_instance!("456")w
      ** (Ecto.NoResultsError)

  """
  @spec get_instance!(id :: String.t()) :: %__MODULE__{}
  def get_instance!(id), do: Repo.get!(__MODULE__, id)

  @spec get_instance!(Ecto.Multi.t(), atom(), String.t()) :: Ecto.Multi.t()
  def get_instance!(multi, name, instance_id) do
    Ecto.Multi.run(multi, name, fn repo, _changes ->
      {:ok, repo.get!(__MODULE__, instance_id)}
    end)
  end

  @doc """
  Creates an instance.

  ## Examples

      iex> create_instance(%{field: value})
      {:ok, %__MODULE__{}}

      iex> create_instance(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_instance(attributes :: map()) :: {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
  def create_instance(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an instance.

  ## Examples

      iex> update_instance(instance, %{field: new_value})
      {:ok, %__MODULE__{}}

      iex> update_instance(instance, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_instance(instance :: %__MODULE__{}, attributes :: map()) ::
          {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
  def update_instance(instance, attrs) do
    instance
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an instance.

  ## Examples

      iex> delete_instance(instance)
      {:ok, %__MODULE__{}}

      iex> delete_instance(instance)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_instance(instance :: %__MODULE__{}) ::
          {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
  def delete_instance(instance) do
    Repo.delete(instance)
  end

  #
  # Private Functions
  #

  @doc false
  @spec changeset(instance :: %__MODULE__{}, attributes :: map()) :: %Ecto.Changeset{}
  defp changeset(instance, attrs) do
    instance
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
