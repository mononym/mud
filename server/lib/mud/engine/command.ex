defmodule Mud.Engine.Command do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  require Protocol

  @derive Jason.Encoder
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "commands" do
    field(:description, :string)
    field(:name, :string)
    field(:instance_id, :binary_id)
    field(:lua_script_id, :binary_id)

    embeds_many :segments, Segment, on_replace: :delete do
      @derive Jason.Encoder
      field(:match, :string, default: "")
      field(:key, :string, default: "")
      field(:greedy, :boolean, default: true)
      field(:dropWhitespace, :boolean, default: false)
      field(:transformer, :string, default: "none")
      field(:type, :string, default: "text")
      field(:multiple, :string, default: "none")
      field(:follows, {:array, :string}, default: [])
    end

    timestamps()
  end

  @doc """
  Returns the list of commands.

  ## Examples

      iex> list()
      [%Command{}, ...]

  """
  def list do
    Repo.all(__MODULE__)
  end

  @doc """
  Returns the list of character_templates.

  ## Examples

      iex> list_by_instance(instance_id)
      [%Command{}, ...]

  """
  def list_by_instance(instance_id) do
    Repo.all(from(command in __MODULE__, where: command.instance_id == ^instance_id))
  end

  @doc """
  Gets a single command.

  Raises `Ecto.NoResultsError` if the Command does not exist.

  ## Examples

      iex> get!(123)
      %Command{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  def get!(id), do: Repo.get!(__MODULE__, id)

  @doc """
  Creates a command.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Command{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> __MODULE__.changeset(attrs)
    |> Repo.insert()
    |> IO.inspect(label: :inserted)
  end

  @doc """
  Updates a command.

  ## Examples

      iex> update(command, %{field: new_value})
      {:ok, %Command{}}

      iex> update(command, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%__MODULE__{} = command, attrs) do
    command
    |> __MODULE__.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a command.

  ## Examples

      iex> delete(command)
      {:ok, %Command{}}

      iex> delete(command)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%__MODULE__{} = command) do
    Repo.delete(command)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking command changes.

  ## Examples

      iex> change(command)
      %Ecto.Changeset{data: %Command{}}

  """
  def change(%__MODULE__{} = command, attrs \\ %{}) do
    __MODULE__.changeset(command, attrs)
  end

  @doc false
  def changeset(command, attrs) do
    command
    |> cast(attrs, [:name, :description, :instance_id, :lua_script_id])
    |> cast_embed(:segments, with: &segment_changeset/2)
    |> validate_required([:name, :description, :segments, :instance_id, :lua_script_id])
  end

  defp segment_changeset(schema, params) do
    schema
    |> cast(params, [:match, :key, :greedy, :dropWhitespace, :transformer, :type, :multiple, :follows])
    |> validate_required([:match, :key, :type])
  end
end
