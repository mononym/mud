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
  Returns the list of templates.

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
  Gets a single template.

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
  Creates a template.

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
  Updates a template.

  ## Examples

      iex> update(template, %{field: new_value})
      {:ok, %__MODULE__{}}

      iex> update(template, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update(template :: %__MODULE__{}, attributes :: map()) ::
          {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
  def update(template, attrs) do
    template
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a template.

  ## Examples

      iex> delete(template)
      {:ok, %__MODULE__{}}

      iex> delete(template)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete(template :: %__MODULE__{}) :: {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
  def delete(template) do
    Repo.delete(template)
  end

  #
  # Private Functions
  #

  @doc false
  @spec changeset(template :: %__MODULE__{}, attributes :: map()) :: %Ecto.Changeset{}
  defp changeset(template, attrs) do
    template
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
    |> foreign_key_constraint(:template_id)
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
    from(template in __MODULE__)
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
