defmodule Mud.Engine.ScriptData do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Engine.Util
  alias Mud.Engine.Script
  alias Mud.Repo
  require Logger

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "script_data" do
    field(:callback_module, Mud.DataType.CallbackModule)
    field(:state, Mud.DataType.Data)
    field(:key, :string)

    belongs_to(:area, Mud.Engine.Area, type: :binary_id)
    belongs_to(:character, Mud.Engine.Character, type: :binary_id)
    belongs_to(:item, Mud.Engine.Item, type: :binary_id)
    belongs_to(:link, Mud.Engine.Link, type: :binary_id)

    timestamps()
  end

  @doc false
  def changeset(state, attrs) do
    state
    |> cast(attrs, [:key, :callback_module, :area_id, :character_id, :item_id, :link_id, :state])
    |> validate_required([:key, :callback_module, :state])
  end

  @spec new(:invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}) ::
          Ecto.Changeset.t()
  def new(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def exists?(thing, key) do
    not is_nil(Repo.one(script_query(thing, key)))
  end

  def create!(attrs) do
    attrs
    |> new()
    |> Repo.insert!()
  end

  def get(thing, key) do
    Logger.debug(inspect({thing, key}))

    case Repo.one(script_query(thing, key)) do
      nil ->
        Logger.info("Script `#{key}` not found in the database for Object `#{thing.id}`.")

        {:error, :no_such_script}

      state ->
        Logger.info("Script `#{key}` loaded from database for Object `#{thing.id}`.")

        {:ok, state}
    end
  end

  def delete(thing, key) do
    Repo.delete(script_query(thing, key))
  end

  @doc """
  Update the state of a Script in the database.

  Primarily used by the Engine to persist the state of a running Script whenever it changes.
  """
  def update(thing, key, state) do
    query = from(script in script_query(thing, key), select: script)

    case Repo.update_all(query, set: [state: Util.pack_term(state)]) do
      {1, [data]} -> {:ok, data}
      {0, _} -> {:error, :no_such_script}
    end
  end

  @doc """
  Update the state of a Script in the database.

  Primarily used by the Engine to persist the state of a running Script whenever it changes.
  """
  def update!(script = %__MODULE__{}, attrs) do
    script
    |> changeset(attrs)
    |> Repo.update!()
  end

  @doc """
  Purge Script data from the database.

  This method does not check for a running Script, or in any way ensure that the state can't or won't be rewritten.
  It is a dumb delete.
  """
  def purge(thing, key) do
    script_query(thing, key)
    |> Repo.delete_all()
    |> case do
      {1, _} -> :ok
      {0, _} -> {:error, :no_such_script}
    end
  end

  @doc """
  Purge Script data from the database.

  This method does not check for a running Script, or in any way ensure that the state can't or won't be rewritten.
  It is a dumb delete.
  """
  def purge(script = %__MODULE__{}) do
    Repo.delete(script)
  end

  def list_all_on_thing(thing) do
    script_all_query(thing)
    |> Repo.all()
  end

  defp script_query(thing, key) do
    field_query = [
      {Script.thing_to_id_key(thing), "#{thing.id}"},
      {:key, key}
    ]

    from(
      stat in __MODULE__,
      where: ^field_query
    )
  end

  defp script_all_query(thing) do
    field_query = [
      {Script.thing_to_id_key(thing), thing.id}
    ]

    from(
      state in __MODULE__,
      where: ^field_query
    )
  end
end
