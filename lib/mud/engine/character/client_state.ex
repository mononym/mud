defmodule Mud.Engine.Character.ClientState do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  require Logger

  @type id :: String.t()

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "character_client_states" do
    belongs_to(:character, Mud.Engine.Character, type: :binary_id)
    field(:state, Mud.DataType.Data, default: %{})
  end

  @doc false
  def changeset(client_state, attrs) do
    client_state
    |> cast(attrs, [
      :character_id,
      :state
    ])
    |> foreign_key_constraint(:character_id)
  end

  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert!()
  end

  def update!(client_state) do
    client_state
    |> change()
    |> Repo.update!()
  end

  @spec get_by_character_id(character_id :: binary) :: nil | [%__MODULE__{}]
  def get_by_character_id(character_id) when is_binary(character_id) do
    from(
      client_state in __MODULE__,
      where: client_state.character_id == ^character_id
    )
    |> Repo.one()
  end

  def load_or_create(character_id) do
    case get_by_character_id(character_id) do
      nil ->
        create(%{character_id: character_id})

      state ->
        state
    end
  end

  def modify(client_state, key, value) do
    data = Ecto.Changeset.fetch_field!(client_state, :state)
    data = Map.put(data, key, value)

    changeset(client_state, %{:state => data})
  end
end
