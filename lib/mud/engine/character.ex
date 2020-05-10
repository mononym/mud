defmodule Mud.Engine.Character do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Mud.Repo
  alias Mud.Engine.Component.{CharacterAttributes, CharacterPhysicalFeatures}

  defmodule AttributeModifier do
    @enforce_keys [:attribute, :modifier, :amount]
    defstruct attribute: nil, modifier: nil, amount: nil
  end

  defmodule PhysicalFeatureSet do
    @enforce_keys [:name]
    defstruct name: nil, description: nil
  end

  defmodule Feature do
    @enforce_keys [:name, :options]
    defstruct name: nil, options: nil, physical_feature_sets: [], required: false, order: nil
  end

  defmodule BodyPart do
    defstruct name: nil, body_parts: [], features: []
  end

  schema "characters" do
    field(:name, :string)
    field(:active, :boolean, default: false)

    belongs_to(:location, Mud.Engine.Area,
      type: :binary_id,
      foreign_key: :location_id
    )

    belongs_to(:player, Mud.Account.Player,
      type: :binary_id,
      foreign_key: :player_id
    )

    has_one(:attributes, CharacterAttributes)
    has_one(:physical_features, CharacterPhysicalFeatures)
  end

  @doc false
  def changeset(character, attrs) do
    character
    |> cast(attrs, [:active, :location_id, :name, :player_id])
    |> validate_required([:active, :location_id, :name, :player_id])
    |> foreign_key_constraint(:location_id)
    |> foreign_key_constraint(:player_id)
    |> validate_inclusion(:active, [true, false])
    |> unique_constraint(:name)
  end

  @spec list_names_by_case_insensitive_prefix_in_area(String.t(), String.t()) :: [%__MODULE__{}]
  def list_names_by_case_insensitive_prefix_in_area(partial_name, character_id) do
    Repo.all(
      from(
        character in case_insensitive_query(partial_name, character_id),
        select: character.name
      )
    )
  end

  @spec list_by_player_id(String.t()) :: [%__MODULE__{}]
  def list_by_player_id(player_id) do
    from(character in __MODULE__,
      where: character.player_id == ^player_id
    )
    |> Repo.all()
  end

  @spec get_by_name(String.t()) :: %__MODULE__{} | nil
  def get_by_name(name) do
    Repo.get_by(__MODULE__, name: name)
  end

  @spec list_by_name_in_area(String.t(), String.t()) :: [%__MODULE__{}]
  def list_by_name_in_area(name, area_id) do
    Repo.all(
      from(
        character in __MODULE__,
        join: attributes in assoc(character, :attributes),
        where: character.location_id == ^area_id and character.name == ^name,
        join: physical_features in assoc(character, :physical_features),
        where: character.id == physical_features.character_id,
        preload: [attributes: attributes, physical_features: physical_features]
      )
    )
  end

  defp case_insensitive_query(partial_name, character_id) do
    subset_query =
      from(
        character in __MODULE__,
        where: character.id == ^character_id
      )

    from(
      character in __MODULE__,
      join: char in subquery(subset_query),
      on: char.location_id == character.location_id,
      where: character.id != ^character_id and like(character.name, ^"#{partial_name}%")
    )
  end
end
