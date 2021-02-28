defmodule Mud.Engine.Character.Status do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  require Logger

  @type id :: String.t()

  @derive {Jason.Encoder, only: [:id, :position, :character_id]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "character_status" do
    belongs_to(:character, Mud.Engine.Character, type: :binary_id)

    field(:position, :string, default: "standing")
  end

  @doc false
  def changeset(wealth, attrs) do
    wealth
    |> change()
    |> cast(attrs, [
      :character_id,
      :position
    ])
    |> validate_required([:character_id, :position])
    |> foreign_key_constraint(:character_id)
  end

  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert!()

    :ok
  end

  def update!(character_id, attrs) when is_binary(character_id) do
    wealth = Repo.get_by!(__MODULE__, character_id: character_id)

    changed = changeset(wealth, attrs)

    Repo.update!(changed)
  end

  def update!(wealth, attrs) do
    wealth
    |> changeset(attrs)
    |> Repo.update!()
  end

  def update(wealth, attrs) do
    wealth
    |> changeset(attrs)
    |> Repo.update()
  end

  @spec get!(id :: binary) :: %__MODULE__{}
  def get!(id) when is_binary(id) do
    from(
      wealth in __MODULE__,
      where: wealth.id == ^id
    )
    |> Repo.one!()
  end

  @spec get(id :: binary) :: nil | %__MODULE__{}
  def get(id) when is_binary(id) do
    from(
      wealth in __MODULE__,
      where: wealth.id == ^id
    )
    |> Repo.one()
  end

  @spec get_by_character!(character_id :: binary) :: %__MODULE__{}
  def get_by_character!(character_id) when is_binary(character_id) do
    Repo.get_by!(__MODULE__, character_id: character_id)
  end

  @spec get_by_character(character_id :: binary) :: nil | %__MODULE__{}
  def get_by_character(character_id) when is_binary(character_id) do
    Repo.get_by(__MODULE__, character_id: character_id)
  end
end
