defmodule Mud.Engine.Model.Character do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Mud.Repo
  alias Mud.Engine.Model.{Area, Character, Item}

  require Logger

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
    field(:agility, :integer, default: 10)
    field(:charisma, :integer, default: 10)
    field(:constitution, :integer, default: 10)
    field(:dexterity, :integer, default: 10)
    field(:intelligence, :integer, default: 10)
    field(:reflexes, :integer, default: 10)
    field(:stamina, :integer, default: 10)
    field(:strength, :integer, default: 10)
    field(:wisdom, :integer, default: 10)

    # Physical Features
    field(:eye_color, :string, default: "Brown")
    field(:hair_color, :string, default: "Brown")
    field(:race, :string, default: "Human")
    field(:skin_color, :string, default: "Brown")

    #
    # Physical Status
    #

    # standing, sitting, kneeling, etc...
    field(:position, :string, default: "standing")

    # on, under, over, in
    field(:relative_position, :string)

    # the thing the Character is relative to
    belongs_to(:relative_item, Item, type: :binary_id)

    # The Object where the
    belongs_to(:area, Area, type: :binary_id)

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
    |> cast(attrs, [
      :active,
      :agility,
      :area_id,
      :charisma,
      :constitution,
      :dexterity,
      :eye_color,
      :hair_color,
      :intelligence,
      :name,
      :player_id,
      :position,
      :race,
      :reflexes,
      :relative_item_id,
      :relative_position,
      :skin_color,
      :stamina,
      :strength,
      :wisdom
    ])
    |> validate_required([
      :active,
      # :agility,
      # :area_id,
      # :charisma,
      # :constitution,
      # :dexterity,
      # :eye_color,
      # :hair_color,
      # :intelligence,
      :name,
      :player_id,
      :position
      # :race,
      # :reflexes,
      # :skin_color,
      # :stamina,
      # :strength,
      # :wisdom
    ])
    |> foreign_key_constraint(:player_id)
    |> validate_inclusion(:active, [true, false])
    |> unsafe_validate_unique(:name, Mud.Repo)
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
    area = Area.list_all() |> Enum.random()

    Logger.debug(inspect(area))
    Logger.debug(inspect(attrs))

    # TODO: Figure out where to create characters and how to present the options.
    # This random selection is just for prototype.
    %__MODULE__{}
    |> changeset(Map.put(attrs, "area_id", area.id))
    |> Repo.insert()
  end

  def change(character), do: Ecto.Changeset.change(character)

  def new, do: %__MODULE__{}

  @doc """
  Describes a character in brief.

  ## Examples

      iex> describe_glance(character)
      "awesome description"

  """
  @spec describe_glance(Character.t(), Character.t()) :: String.t()
  def describe_glance(character, _character_doing_the_looking) do
    a_or_an =
      if Regex.match?(~r/^[aeiouAEIOU]/, character.race) do
        "an"
      else
        "a"
      end

    "#{character.name} is #{a_or_an} #{character.race}. They have #{character.hair_color} hair, #{
      character.eye_color
    } eyes, and #{character.skin_color} skin."
  end

  @doc """
  Describes a character in detail.

  ## Examples

      iex> describe_look(character)
      "awesome description"

  """
  @spec describe_look(Character.t(), Character.t()) :: String.t()
  def describe_look(character, looking_character) do
    describe_glance(character, looking_character)
  end

  def describe_room_glance(character, _looking_character) do
    position_string =
      cond do
        character.relative_item_id != nil ->
          desc = Item.describe_glance(Item.get!(character.relative_item_id), character)

          " who is #{character.position} #{character.relative_position} #{desc}"

        character.position != "standing" ->
          " who is #{character.position}"

        true ->
          ""
      end

    character.name <> position_string
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
    |> where([character], character.area_id == ^area_id)
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
  @spec list_active_in_areas(String.t() | [String.t()]) :: [%__MODULE__{}]
  def list_active_in_areas(area_ids) do
    area_ids = List.wrap(area_ids)

    base_query()
    |> where([character], character.active == true and character.area_id in ^area_ids)
    |> Repo.all()
  end

  @doc """
  Returns the list of characters that are both active and in the same area as the provided character.

  ## Examples

      iex> list_others_active_in_areas(42)
      [%Character{}, ...]

      iex> list_others_active_in_areas([42, 24])
      [%Character{}, ...]

  """
  @spec list_others_active_in_areas(Character.t(), String.t() | [String.t()]) :: [%__MODULE__{}]
  def list_others_active_in_areas(character, area_ids) do
    area_ids = List.wrap(area_ids)

    base_query()
    |> where(
      [char],
      char.active == true and char.area_id in ^area_ids and
        char.id != ^character.id
    )
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
    |> where([character], character.name == ^name and character.area_id == ^area_id)
    |> Repo.all()
  end

  @doc """
  Updates a character.

  ## Examples

      iex> update(character, %{field: new_value})
      {:ok, %__MODULE__{}}

      iex> update(character, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update(character :: __MODULE__.t(), attributes :: map()) ::
          {:ok, __MODULE__.t()} | {:error, %Ecto.Changeset{}}
  def update(character, attrs \\ %{}) do
    character
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a character.

  Raises `Ecto.NoResultsError` if the Character does not exist.

  ## Examples

      iex> update!(character, %{field: new_value})
      %Character{}

      iex> update!(character, %{field: bad_value})
      ** (Ecto.NoResultsError)

  """
  @spec update!(character :: __MODULE__.t(), attributes :: map()) :: __MODULE__.t()
  def update!(character, attrs \\ %{}) do
    character
    |> changeset(attrs)
    |> Repo.update!()
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

  @spec standing :: <<_::64>>
  def standing, do: "standing"

  def sitting, do: "sitting"

  def kneeling, do: "kneeling"

  def crouching, do: "crouching"

  def prone, do: "prone"

  defp base_query do
    from(character in __MODULE__)
  end
end
