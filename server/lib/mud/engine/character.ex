defmodule Mud.Engine.Character do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Mud.Repo
  alias Mud.Engine.{Area, Character, Item}
  alias Mud.Engine.Util
  alias Mud.Engine.Character.Skill
  alias Mud.DataType.NameSlug

  require Logger

  ##
  ##
  # Defining the data object
  ##
  ##

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "characters" do
    @derive Jason.Encoder
    has_many(:worn_items, Item, foreign_key: :wearable_worn_by_id)
    has_many(:held_items, Item, foreign_key: :holdable_held_by_id)

    timestamps()
    # Naming and Titles
    field(:name, :string)
    field(:slug, NameSlug.Type)

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
    field(:age, :integer, default: 18)
    field(:eye_color, :string, default: "brown")
    field(:eye_color_type, :string, default: "solid")
    field(:eye_accent_color, :string, default: "brown")
    field(:hair_color, :string, default: "brown")
    field(:hair_length, :string, default: "short")
    field(:hair_style, :string, default: "loose")
    field(:race, :string, default: "Human")
    field(:skin_tone, :string, default: "brown")
    field(:height, :string, default: "average")

    # Which hand is the primary hand
    field(:handedness, :string, default: "right")

    # Gender pronoun
    field(:gender_pronoun, :string, default: "neutral")

    #
    # Physical Status
    #

    # standing, sitting, kneeling, etc...
    field(:position, :string, default: "standing")

    # on, under, over, in
    # field(:relative_position, :string)

    # the thing the Character is relative to
    # belongs_to(:relative_item, Item, type: :binary_id)

    # The Object where the
    belongs_to(:area, Area, type: :binary_id)

    #
    # Player related stuff
    #

    belongs_to(:player, Mud.Account.Player, type: :binary_id)

    #
    # Settings
    #

    field(:auto_open_containers, :boolean, default: false)
    field(:auto_close_containers, :boolean, default: false)
    field(:auto_unlock_containers, :boolean, default: false)
    field(:auto_lock_containers, :boolean, default: false)

    #
    # Skills
    #

    has_many(:raw_skills, Skill)
  end

  ##
  ##
  # Public API
  ##
  ##

  @doc false
  def changeset(character, attrs) do
    # IO.inspect(Ecto.Changeset.change(character), label: "attrs")

    # IO.inspect(
    #   cast(character, attrs, [
    #     :active,
    #     :age,
    #     :agility,
    #     :area_id,
    #     :charisma,
    #     :constitution,
    #     :dexterity,
    #     :eye_accent_color,
    #     :eye_color,
    #     :eye_color_type,
    #     :height,
    #     :hair_color,
    #     :hair_length,
    #     :hair_style,
    #     :intelligence,
    #     :name,
    #     :player_id,
    #     :position,
    #     :race,
    #     :reflexes,
    #     :relative_item_id,
    #     :relative_position,
    #     :skin_tone,
    #     :stamina,
    #     :strength,
    #     :wisdom,
    #     :handedness
    #   ]),
    #   label: "attrs"
    # )

    character
    # |> Ecto.Changeset.change()
    |> Ecto.Changeset.cast(attrs, [
      :active,
      :age,
      :agility,
      :area_id,
      :charisma,
      :constitution,
      :dexterity,
      :eye_accent_color,
      :eye_color,
      :eye_color_type,
      :height,
      :hair_color,
      :hair_length,
      :hair_style,
      :intelligence,
      :name,
      :player_id,
      :position,
      :race,
      :reflexes,
      :skin_tone,
      :stamina,
      :strength,
      :wisdom,
      :handedness
    ])
    |> validate_required([
      :name,
      :player_id
    ])
    |> foreign_key_constraint(:player_id)
    |> validate_inclusion(:active, [true, false])
    |> unsafe_validate_unique(:name, Mud.Repo)
    |> unique_constraint(:name)
    |> NameSlug.maybe_generate_slug()
    |> NameSlug.unique_constraint()
  end

  @topic inspect(__MODULE__)

  @doc """
  Subscribe to the PubSub topic for all Character events.
  """
  @spec subscribe :: {:ok, :subscribed}
  def subscribe do
    :ok = Phoenix.PubSub.subscribe(Mud.PubSub, @topic)
    {:ok, :subscribed}
  end

  @doc """
  Subscribe to the PubSub topic for all Character events related to a single Character.
  """
  @spec subscribe(String.t()) :: {:ok, :subscribed}
  def subscribe(character_id) when is_binary(character_id) do
    :ok = Phoenix.PubSub.subscribe(Mud.PubSub, @topic <> ":#{character_id}")
    {:ok, :subscribed}
  end

  @doc """
  Creates a Character.

  ## Examples

      iex> create(%{field: value})
      {:ok, %__MODULE__{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create(attributes :: map()) :: {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
  def create(attrs \\ %{}) do
    area = Area.list_all() |> Enum.random()

    Logger.debug(inspect(area))
    Logger.debug(inspect(attrs))

    # TODO: Figure out where to create characters and how to present the options.
    # This random selection is just for prototype.

    result =
      %__MODULE__{}
      |> changeset(Map.put(attrs, "area_id", area.id))
      |> Repo.insert()

    case result do
      {:ok, character} ->
        :ok = Skill.initialize(character.id)

        {:ok, character}

      error ->
        error
    end
  end

  def new, do: %__MODULE__{}

  @doc """
  Describes a character in brief.

  ## Examples

      iex> short_description(character)
      "awesome description"

  """
  @spec short_description(%Character{}) :: String.t()
  def short_description(character) do
    a_or_an =
      if Regex.match?(~r/^[aeiouAEIOU]/, character.race) do
        "an"
      else
        "a"
      end

    "#{character.name} is #{a_or_an} #{character.race}. They have #{character.hair_color} hair, #{
      character.eye_color
    } eyes, and #{character.skin_tone} skin."
  end

  @doc """
  Describes a character in detail.

  ## Examples

      iex> long_description(character)
      "awesome description"

  """
  @spec long_description(%Character{}) :: String.t()
  def long_description(character) do
    # Woodsman Khandrish Aratar of Zoulren, an Elf.
    # Of average height, they have blue eyes and brown hair.
    # They are wearing a rugged leather backpack.
    character = Repo.preload(character, :worn_items)

    worn_items =
      character.worn_items
      |> Stream.map(& &1.short_description)
      |> Enum.join("{{/item}}, {{item}}")

    worn_items_string = "{{item}}" <> worn_items <> "{{/item}}"

    "{{character}}#{character.name}{{/character}}, #{Util.prefix_with_a_or_an(character.race)}.\n" <>
      "They are wearing #{worn_items_string}"
  end

  def describe_room_glance(character) do
    position_string =
      cond do
        character.relative_item_id != nil ->
          item = Item.get!(character.relative_item_id)

          " who is #{character.position} #{character.relative_position} #{item.short_description}"

        character.position != standing() ->
          " who is #{character.position}"

        true ->
          ""
      end

    character.name <> position_string
  end

  @spec list_by_case_insensitive_prefix_in_area(String.t(), String.t()) :: [%__MODULE__{}]
  def list_by_case_insensitive_prefix_in_area(partial_name, character_id) do
    base_no_skills_query(character_id)
    |> where(
      [character: character],
      like(character.name, ^"#{partial_name}%")
    )
    |> Repo.all()
  end

  def list_worn_containers(character) do
    Item.list_worn_containers(character.id)
  end

  def list_held_items(character) when is_struct(character) do
    Item.list_held_by(character.id)
  end

  def list_held_items(character_id) do
    Item.list_held_by(character_id)
  end

  def list_worn_items(character) when is_struct(character) do
    Item.list_worn_by(character.id)
  end

  def list_worn_items(character_id) do
    Item.list_worn_by(character_id)
  end

  @doc """
  Returns a list of characters all characters.

  ## Examples

      iex> list_all()
      [%Character{}, ...]

  """
  @spec list(list_of_ids :: [String.t(), ...]) :: [%__MODULE__{}]
  def list(list_of_ids) do
    base_no_skills_query()
    |> where([character], character.id in ^list_of_ids)
    |> Repo.all()
  end

  @doc """
  Returns a list of characters all characters.

  ## Examples

      iex> list_all()
      [%Character{}, ...]

  """
  @spec list_all :: [%__MODULE__{}]
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
    base_no_skills_query()
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

    base_no_skills_query()
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
  @spec list_others_active_in_areas(String.t(), String.t() | [String.t()]) :: [%__MODULE__{}]
  def list_others_active_in_areas(character_id, area_ids) do
    area_ids = List.wrap(area_ids)

    base_no_skills_query()
    |> where(
      [char],
      char.active == true and char.area_id in ^area_ids and
        char.id != ^character_id
    )
    |> Repo.all()
  end

  @spec list_others_active_in_areas(Ecto.Multi.t(), atom(), String.t(), String.t() | [String.t()]) ::
          Ecto.Multi.t()
  def list_others_active_in_areas(multi, name, character_id, area_ids) do
    Ecto.Multi.run(multi, name, fn repo, _changes ->
      area_ids = List.wrap(area_ids)

      base_no_skills_query()
      |> where(
        [char],
        char.active == true and char.area_id in ^area_ids and
          char.id != ^character_id
      )
      |> repo.all()
      |> (&{:ok, &1}).()
    end)
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

  @doc """
  Gets a single character.

  Raises `Ecto.NoResultsError` if the Character does not exist.

  ## Examples

      iex> get_by_slug!(123)
      %Character{}

      iex> get_by_slug!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_by_slug!(String.t()) :: %__MODULE__{} | nil
  def get_by_slug!(character_slug) do
    Repo.one!(from(character in __MODULE__, where: character.slug == ^character_slug))
  end

  @doc """
  Gets a single character.

  Raises `Ecto.NoResultsError` if the Character does not exist.

  ## Examples

      iex> get_with_skills_by_id!(123)
      %Character{}

      iex> get_with_skills_by_id!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_with_skills_by_id!(String.t()) :: %__MODULE__{} | nil
  def get_with_skills_by_id!(character_id) do
    Repo.one!(base_skills_query(character_id))
  end

  @doc """
  Updates a character.

  ## Examples

      iex> update(character, %{field: new_value})
      {:ok, %__MODULE__{}}

      iex> update(character, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update(character :: %__MODULE__{}, attributes :: map()) ::
          {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
  def update(character, attrs \\ %{}) do
    character
    |> changeset(attrs)
    |> Repo.update()
  end

  def update!(character_id, attrs) when is_binary(character_id) do
    keywords =
      attrs
      |> Keyword.new()
      |> Keyword.put_new(:updated_at, Timex.now())

    character =
      from(character in __MODULE__, where: character.id == ^character_id, select: character)
      |> Repo.update_all(set: keywords)
      |> elem(1)
      |> List.first()

    Util.notify_subscribers(character, @topic, :updated)

    character
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
  @spec update!(character :: %__MODULE__{}, attributes :: map()) :: %__MODULE__{}
  def update!(character, attrs) do
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
  @spec delete(character :: %__MODULE__{}) :: {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
  def delete(character) do
    Repo.delete(character)
  end

  @doc """
  Given a list of items that they currently hold in their hands, return the hand to put an item into.

  In the case of a single held item the hand returned is the opposite one. If there are no held items the right hand
  will be chosen as a default.
  """
  @spec which_hand([Item.t()]) :: String.t()
  def which_hand(held_items) when length(held_items) < 2 do
    case held_items do
      [item] ->
        if item.holdable_hand == "left" do
          "right"
        else
          "left"
        end

      _items ->
        "right"
    end
  end

  @spec standing :: <<_::64>>
  def standing, do: "standing"

  def sitting, do: "sitting"

  def kneeling, do: "kneeling"

  def crouching, do: "crouching"

  def prone, do: "prone"

  defp base_no_skills_query() do
    from(character in __MODULE__)
  end

  defp base_no_skills_query(character_id) do
    from(
      character in __MODULE__,
      where: character.id == ^character_id
    )
  end

  defp base_skills_query(character_id) do
    from(
      character in __MODULE__,
      join: skills in assoc(character, :skills),
      where: character.id == skills.character_id and character.id == ^character_id,
      preload: [skills: skills]
    )
  end
end
