defmodule Mud.Engine.Character do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Mud.Repo

  alias Mud.Engine.Component.{
    CharacterAttributes,
    CharacterPhysicalFeatures,
    CharacterPhysicalStatus
  }

  schema "characters" do
    field(:name, :string)
    field(:active, :boolean, default: false)

    belongs_to(:player, Mud.Account.Player,
      type: :binary_id,
      foreign_key: :player_id
    )

    has_one(:attributes, CharacterAttributes)
    has_one(:physical_features, CharacterPhysicalFeatures)
    has_one(:physical_status, CharacterPhysicalStatus)
  end

  @doc false
  def changeset(character, attrs) do
    character
    |> cast(attrs, [:active, :name, :player_id])
    |> validate_required([:active, :name, :player_id])
    |> foreign_key_constraint(:player_id)
    |> validate_inclusion(:active, [true, false])
    |> unique_constraint(:name)
  end

  @spec list_by_case_insensitive_prefix_in_area(String.t(), String.t()) :: [%__MODULE__{}]
  def list_by_case_insensitive_prefix_in_area(partial_name, character_id) do
    base_query()
    |> where(
      [character: character],
      character.id == ^character_id and like(character.name, ^"#{partial_name}%")
    )
    |> Repo.all()
  end

  @doc """
  Returns the list of characters that belong to a player.

  ## Examples

      iex> list_characters_by_player(good_player_id)
      [%Character{}, ...]

      iex> list_characters_by_player(good_or_bad_player_id)
      []

  """
  @spec list_by_player_id(String.t()) :: [%__MODULE__{}]
  def list_by_player_id(player_id) do
    from(character in __MODULE__,
      where: character.player_id == ^player_id
    )
    |> Repo.all()
  end

  @doc """
  Returns the list of characters that are in the given area(s).

  ## Examples

      iex> list_in_area(42)
      [%Character{}, ...]

      iex> list_in_area([42, 24])
      [%Character{}, ...]

  """
  @spec list_in_area(String.t()) :: [%__MODULE__{}]
  def list_in_area(area_id) do
    base_query()
    |> where([physical_status: physical_status], physical_status.area_id == ^area_id)
    |> Repo.all()
  end

  @doc """
  Returns the list of characters that are both active and in the given area(s).

  ## Examples

      iex> list_active_in_areas(42)
      [%Character{}, ...]

      iex> list_active_in_areas([42, 24])
      [%Character{}, ...]

  """
  @spec list_active_in_areas([String.t()]) :: [%__MODULE__{}]
  def list_active_in_areas(area_ids) do
    base_query()
    |> where([character: character], character.active == true)
    |> where([physical_status: physical_status], physical_status.area_id in ^area_ids)
    |> Repo.all()
  end

  @spec get_by_name(String.t()) :: %__MODULE__{} | nil
  def get_by_name(name) do
    Repo.get_by(__MODULE__, name: name)
  end

  @spec get_by_id(String.t()) :: %__MODULE__{} | nil
  def get_by_id(character_id) do
    Repo.get(__MODULE__, character_id)
  end

  @doc """
  Gets a single character.

  Raises `Ecto.NoResultsError` if the Character does not exist.

  ## Examples

      iex> get_by_id!(123)
      %Character{}

      iex> get_by_id!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_by_id!(String.t()) :: %__MODULE__{} | nil
  def get_by_id!(character_id) do
    Repo.get!(__MODULE__, character_id)
  end

  @spec list_by_name_in_area(String.t(), String.t()) :: [%__MODULE__{}]
  def list_by_name_in_area(name, area_id) do
    base_query()
    |> where([physical_status: physical_status], physical_status.area_id == ^area_id)
    |> where([character: character], character.name == ^name)
    |> Repo.all()
  end

  defp base_query do
    from(
      character in __MODULE__,
      join: attributes in assoc(character, :attributes),
      as: :attributes,
      join: physical_features in assoc(character, :physical_features),
      as: :physical_features,
      join: physical_status in assoc(character, :physical_status),
      as: :physical_status,
      preload: [
        attributes: attributes,
        physical_features: physical_features,
        physical_status: physical_status
      ]
    )
  end
end
