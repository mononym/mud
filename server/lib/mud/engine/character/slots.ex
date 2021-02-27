defmodule Mud.Engine.Character.Slots do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  require Logger

  @type id :: String.t()

  @derive {Jason.Encoder,
           only: [
             :id,
             :character_id,
             :on_back,
             :around_waist,
             :on_belt,
             :on_finger,
             :over_shoulders,
             :over_shoulder,
             :on_head,
             :in_hair,
             :on_hair,
             :around_neck,
             :on_torso,
             :on_legs,
             :on_feet,
             :on_hands,
             :on_thigh,
             :on_ankle
           ]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "character_slots" do
    belongs_to(:character, Mud.Engine.Character, type: :binary_id)

    field(:on_back, :integer, default: 1)
    field(:around_waist, :integer, default: 3)
    field(:on_belt, :integer, default: 6)
    field(:on_finger, :integer, default: 10)
    field(:over_shoulders, :integer, default: 1)
    field(:over_shoulder, :integer, default: 4)
    field(:on_head, :integer, default: 1)
    field(:in_hair, :integer, default: 1)
    field(:on_hair, :integer, default: 1)
    field(:around_neck, :integer, default: 3)
    field(:on_torso, :integer, default: 1)
    field(:on_legs, :integer, default: 1)
    field(:on_feet, :integer, default: 1)
    field(:on_hands, :integer, default: 1)
    field(:on_thigh, :integer, default: 2)
    field(:on_ankle, :integer, default: 4)
  end

  @doc false
  def changeset(slots, attrs) do
    slots
    |> change()
    |> cast(attrs, [
      :character_id,
      :on_back,
      :around_waist,
      :on_belt,
      :on_finger,
      :over_shoulders,
      :over_shoulder,
      :on_head,
      :in_hair,
      :on_hair,
      :around_neck,
      :on_torso,
      :on_legs,
      :on_feet,
      :on_hands,
      :on_thigh,
      :on_ankle
    ])
    |> validate_required([:character_id])
    |> foreign_key_constraint(:character_id)
  end

  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert!()

    :ok
  end

  def update!(character_id, attrs) when is_binary(character_id) do
    slots = Repo.get_by!(__MODULE__, character_id: character_id)

    changed = changeset(slots, attrs)

    Repo.update!(changed)
  end

  def update!(slots, attrs) do
    slots
    |> changeset(attrs)
    |> Repo.update!()
  end

  def update(slots, attrs) do
    slots
    |> changeset(attrs)
    |> Repo.update()
  end

  @spec get!(id :: binary) :: %__MODULE__{}
  def get!(id) when is_binary(id) do
    from(
      slots in __MODULE__,
      where: slots.id == ^id
    )
    |> Repo.one!()
  end

  @spec get(id :: binary) :: nil | %__MODULE__{}
  def get(id) when is_binary(id) do
    from(
      slots in __MODULE__,
      where: slots.id == ^id
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
