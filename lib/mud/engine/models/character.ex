defmodule Mud.Engine.Model.Character do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Mud.Repo

  ##
  ##
  # Defining the data object
  ##
  ##

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "characters" do
    # Naming and Titles
    field(:name, :string)

    # Game Status
    field(:active, :boolean, default: false)

    # Attributes
    field(:strength, :integer, default: 10)
    field(:stamina, :integer, default: 10)
    field(:constitution, :integer, default: 10)
    field(:dexterity, :integer, default: 10)
    field(:agility, :integer, default: 10)
    field(:reflexes, :integer, default: 10)
    field(:intelligence, :integer, default: 10)
    field(:wisdom, :integer, default: 10)
    field(:charisma, :integer, default: 10)

    # Physical Features
    field(:race, :string, default: "Human")
    field(:eye_color, :string, default: "Brown")
    field(:hair_color, :string, default: "Brown")
    field(:skin_color, :string, default: "Brown")

    #
    # Physical Status
    #

    # standing, sitting, kneeling, etc...
    field(:position, :string, default: "standing")

    # on, under, over, in
    field(:relative_position, :string)

    # the thing the Character is relative to
    belongs_to(:relative_item, Mud.Engine.Model.Item, type: :binary_id)
    belongs_to(:relative_character, Mud.Engine.Model.Character, type: :binary_id)

    # The Object where the
    belongs_to(:area, Mud.Engine.Model.Area, type: :binary_id)

    #
    # Player related stuff
    #

    belongs_to(:player, Mud.Account.Player, type: :binary_id)
  end

  ##
  ##
  # Public API
  ##
  ##

  @doc false
  def changeset(character, attrs) do
    character
    |> cast(attrs, [:active, :name, :player_id])
    |> validate_required([:active, :name, :player_id])
    |> foreign_key_constraint(:player_id)
    |> validate_inclusion(:active, [true, false])
    |> unique_constraint(:name)
  end

  @doc """
  Creates a Character.

  ## Examples

      iex> create(%{field: value})
      {:ok, %__MODULE__{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create(attributes :: map()) :: {:ok, __MODULE__.t()} | {:error, %Ecto.Changeset{}}
  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Describes a character.

  ## Examples

      iex> describe_character(character)
      "awesome description"

  """
  @spec describe_character(Character.t(), Character.t()) :: String.t()
  def describe_character(character, _character_doing_the_looking) do
    character_physical_features = character.physical_features

    a_or_an =
      if Regex.match?(~r/^[aeiouAEIOU]/, character_physical_features.race) do
        "an"
      else
        "a"
      end

    "#{character.name} is #{a_or_an} #{character_physical_features.race}. They have #{
      character_physical_features.hair_color
    } hair, #{character_physical_features.eye_color} eyes, and #{
      character_physical_features.skin_color
    } skin."
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
  Returns a list of characters all characters.

  ## Examples

      iex> list_all()
      [%Character{}, ...]

  """
  @spec list_all :: [__MODULE__.t()]
  def list_all do
    Repo.all(__MODULE__)
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

  @doc """
  Updates a character.

  ## Examples

      iex> update(area, %{field: new_value})
      {:ok, %__MODULE__{}}

      iex> update(area, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update(area :: __MODULE__.t(), attributes :: map()) ::
          {:ok, __MODULE__.t()} | {:error, %Ecto.Changeset{}}
  def update(area, attrs \\ %{}) do
    area
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a character.

  ## Examples

      iex> delete(character)
      {:ok, %__MODULE__{}}

      iex> delete(character)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete(character :: __MODULE__.t()) :: {:ok, __MODULE__.t()} | {:error, %Ecto.Changeset{}}
  def delete(character) do
    Repo.delete(character)
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
