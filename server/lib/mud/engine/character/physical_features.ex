defmodule Mud.Engine.Character.PhysicalFeatures do
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
             :birth_day,
             :birth_season,
             :birth_year,
             :dominant_hand,
             :eye_shape,
             :eye_feature,
             :eye_color,
             :hair_color,
             :hair_feature,
             :hair_length,
             :hair_style,
             :hair_type,
             :skin_tone,
             :height,
             :body_type
           ]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "physical_features" do
    belongs_to(:character, Mud.Engine.Character, type: :binary_id)

    field(:birth_day, :integer, default: 1)
    field(:birth_season, :string, default: "spring")
    field(:birth_year, :integer, default: 1)
    field(:dominant_hand, :string, default: "right")
    field(:eye_shape, :string, default: "none")
    field(:eye_feature, :string, default: "none")
    field(:eye_color, :string, default: "brown")
    field(:hair_color, :string, default: "brown")
    field(:hair_feature, :string, default: "none")
    field(:hair_length, :string, default: "shoulder length")
    field(:hair_style, :string, default: "none")
    field(:hair_type, :string, default: "wavy")
    field(:skin_tone, :string, default: "brown")
    field(:height, :string, default: "average")
    field(:body_type, :string, default: "average")

    timestamps()
  end

  @doc false
  def changeset(slots, attrs) do
    slots
    |> change()
    |> cast(attrs, [
      :character_id,
      :birth_day,
      :birth_season,
      :birth_year,
      :dominant_hand,
      :eye_shape,
      :eye_feature,
      :eye_color,
      :hair_color,
      :hair_feature,
      :hair_length,
      :hair_style,
      :hair_type,
      :skin_tone,
      :height,
      :body_type
    ])
    |> validate_required([
      :character_id
    ])
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
