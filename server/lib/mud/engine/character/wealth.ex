defmodule Mud.Engine.Character.Wealth do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  require Logger

  @type id :: String.t()

  @derive {Jason.Encoder, only: [:id, :copper, :bronze, :silver, :gold, :character_id]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "character_wealth" do
    belongs_to(:character, Mud.Engine.Character, type: :binary_id)

    field(:copper, :integer, default: 0)
    field(:bronze, :integer, default: 0)
    field(:silver, :integer, default: 0)
    field(:gold, :integer, default: 1)
  end

  @doc false
  def changeset(wealth, attrs) do
    wealth
    |> change()
    |> cast(attrs, [
      :character_id,
      :copper,
      :bronze,
      :silver,
      :gold
    ])
    |> validate_required([:character_id, :copper, :bronze, :silver, :gold])
    |> validate_number(:copper, greater_than_or_equal_to: 0)
    |> validate_number(:bronze, greater_than_or_equal_to: 0)
    |> validate_number(:silver, greater_than_or_equal_to: 0)
    |> validate_number(:gold, greater_than_or_equal_to: 0)
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
