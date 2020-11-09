defmodule Mud.Engine.LuaScript do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  alias Mud.Engine.Instance

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "lua_scripts" do
    field(:code, :string, default: "")
    field(:name, :string)
    field(:type, :string)
    field(:description, :string)
    many_to_many(:dependencies, Mud.Engine.LuaScript, join_through: "lua_scripts_dependencies")
    belongs_to(:instance, Instance, type: :binary_id)

    timestamps()
  end

  @doc false
  def changeset(lua_script, attrs) do
    lua_script
    |> cast(attrs, [:name, :type, :code, :description, :instance_id])
    |> validate_required([:name, :type, :code, :description, :instance_id])
  end

  @doc """
  Returns the list of lua_scripts.

  ## Examples

      iex> lists()
      [%LuaScript{}, ...]

  """
  def list do
    Repo.all(__MODULE__)
  end

  @doc """
  Returns the list of character_templates.

  ## Examples

      iex> list_by_instance(instance_id)
      [%LuaScript{}, ...]

  """
  def list_by_instance(instance_id) do
    Repo.all(from(script in __MODULE__, where: script.instance_id == ^instance_id))
  end

  @doc """
  Gets a single lua_script.

  Raises `Ecto.NoResultsError` if the Lua script does not exist.

  ## Examples

      iex> get!(123)
      %LuaScript{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  def get!(id), do: Repo.get!(__MODULE__, id)

  @doc """
  Fetches a single lua_script by name.

  Raises `Ecto.NoResultsError` if the Lua script does not exist.

  ## Examples

      iex> fetch!("super duper awesome script that really does exist")
      %LuaScript{}

      iex> fetch!("terrible script that nobody wrote")
      ** (Ecto.NoResultsError)

  """
  def fetch!(name), do: Repo.get_by!(__MODULE__, name: name)

  @doc """
  Creates a lua_script.

  ## Examples

      iex> create(%{field: value})
      {:ok, %LuaScript{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> __MODULE__.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a lua_script.

  ## Examples

      iex> update(lua_script, %{field: new_value})
      {:ok, %LuaScript{}}

      iex> update(lua_script, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%__MODULE__{} = lua_script, attrs) do
    lua_script
    |> __MODULE__.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a lua_script.

  ## Examples

      iex> delete(lua_script)
      {:ok, %LuaScript{}}

      iex> delete(lua_script)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%__MODULE__{} = lua_script) do
    Repo.delete(lua_script)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking lua_script changes.

  ## Examples

      iex> change(lua_script)
      %Ecto.Changeset{data: %LuaScript{}}

  """
  def change(%__MODULE__{} = lua_script, attrs \\ %{}) do
    __MODULE__.changeset(lua_script, attrs)
  end
end
