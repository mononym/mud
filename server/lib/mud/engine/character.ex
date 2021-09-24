defmodule Mud.Engine.Character do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Mud.Repo
  alias Mud.Engine.{Area, Character, Item, Shop}
  alias Mud.Engine.Util

  alias Mud.Engine.Character.{
    Bank,
    Containers,
    PhysicalFeatures,
    Settings,
    Skill,
    Slots,
    Status,
    Wealth
  }

  require Logger

  ##
  ##
  # Defining the data object
  ##
  ##
  @derive {Jason.Encoder,
           only: [
             :id,
             :settings,
             :bank,
             :wealth,
             :containers,
             :slots,
             :status,
             :physical_features,
             :name,
             :active,
             :moved_at,
             :agility,
             :charisma,
             :constitution,
             :dexterity,
             :intelligence,
             :reflexes,
             :stamina,
             :strength,
             :wisdom,
             :race,
             :pronoun,
             :area,
             :player
           ]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "characters" do
    has_one(:settings, Settings)
    has_one(:bank, Bank)
    has_one(:wealth, Wealth)
    has_one(:containers, Containers)
    has_one(:slots, Slots)
    has_one(:status, Status)
    has_one(:physical_features, PhysicalFeatures)

    timestamps()
    # Naming and Titles
    field(:name, :string)

    # Game Status
    field(:active, :boolean, default: false)
    field(:moved_at, :utc_datetime_usec, required: true)

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

    # # Physical Features
    field(:race, :string, default: "Human")

    # Pronoun
    field(:pronoun, :string, default: "neutral")

    # The Area that the Character is in
    belongs_to(:area, Area, type: :binary_id)

    #
    # Player related stuff
    #

    belongs_to(:player, Mud.Account.Player, type: :binary_id)

    #
    # Skills
    #

    has_many(:raw_skills, Skill)

    #
    # Things linked to the character
    #

    many_to_many(:maps, Mud.Engine.Map,
      join_through: Mud.Engine.CharactersMaps,
      on_replace: :delete
    )
  end

  ##
  ##
  # Public API
  ##
  ##

  @doc false
  def changeset(character, attrs) do
    character
    |> Ecto.Changeset.cast(attrs, [
      :active,
      :agility,
      :area_id,
      :charisma,
      :constitution,
      :dexterity,
      :pronoun,
      :intelligence,
      :name,
      :player_id,
      :race,
      :reflexes,
      :stamina,
      :strength,
      :wisdom,
      :moved_at
    ])
    |> validate_required([
      :pronoun,
      :name,
      :race,
      :player_id
    ])
    |> foreign_key_constraint(:player_id)
    |> validate_inclusion(:active, [true, false])
    |> unsafe_validate_unique(:name, Mud.Repo)
    |> unique_constraint(:name)
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
    Mud.Repo.transaction(fn ->
      # Just grab something random for Alpha, as long as it is permanently explored
      area = Area.list_all() |> Enum.filter(& &1.flags.permanently_explored) |> Enum.random()

      Logger.debug(inspect(attrs))

      # This random selection is just for prototype.
      attrs =
        attrs
        |> Map.put("area_id", area.id)
        |> Map.put("moved_at", DateTime.utc_now())

      result =
        %__MODULE__{}
        |> changeset(attrs)
        |> Repo.insert()

      case result do
        {:ok, character} ->
          Logger.info("Character `#{character.name}` created in area `#{area.id}:#{area.name}`")

          # Set up skills
          :ok = Skill.initialize(character.id)

          # Set up settings and make sure they are loaded
          :ok = Settings.create(%{character_id: character.id})
          :ok = Wealth.create(%{character_id: character.id})
          :ok = Bank.create(%{character_id: character.id})
          :ok = Slots.create(%{character_id: character.id})
          :ok = Status.create(%{character_id: character.id})
          :ok = Containers.create(%{character_id: character.id})

          :ok =
            PhysicalFeatures.create(
              Map.merge(attrs["physical_features"], %{"character_id" => character.id})
            )

          preload(character)

        error ->
          IO.inspect(error)
          Mud.Repo.rollback(error)
      end
    end)
  end

  # defp setup_default_items(character) do
  #   :ok
  # end

  def new, do: %__MODULE__{}

  @doc """
  In general, characters only 'know about' maps that they have visited at least one room in before.

  This function loads up all the maps which meet that criteria.

  ## Examples

      iex> load_known_maps(character_id)
      [%Mud.Engine.Map{}]

  """
  @spec load_known_maps(String.t()) :: String.t()
  def load_known_maps(character_id) do
    from(
      map in Mud.Engine.Map,
      left_join: character_map in Mud.Engine.CharactersMaps,
      on: character_map.map_id == map.id,
      where: character_map.character_id == ^character_id
    )
    |> Repo.all()
  end

  @doc """
  In general, characters only 'know about' maps that they have visited at least one room in before.

  This function marks one or more maps as being known by a character.

  ## Examples

      iex> mark_map_as_known!(character, map)
      :ok

  """
  @spec mark_maps_as_known!(%Character{}, %Mud.Engine.Map{} | [%Mud.Engine.Map{}]) :: :ok
  def mark_maps_as_known!(character = %Character{}, maps) do
    maps = List.wrap(maps) |> Enum.map(&Ecto.Changeset.change(&1))
    character = Repo.preload(character, [:maps])
    char_chageset = Ecto.Changeset.change(character)
    char_with_map = Ecto.Changeset.put_assoc(char_chageset, :maps, maps)

    Repo.update!(char_with_map)

    :ok
  end

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

    "#{character.name} is #{a_or_an} #{character.race}. They have #{character.physical_features.hair_color} hair, #{character.physical_features.eye_color} eyes, and #{character.physical_features.skin_tone} skin."
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
      |> Stream.map(& &1.description.short)
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

          " who is #{character.position} #{character.relative_position} #{item.description.short}"

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
    |> preload()
  end

  def list_worn_containers(character) when is_struct(character) do
    Item.list_worn_containers(character.id)
  end

  def list_worn_containers(character_id) when is_binary(character_id) do
    Item.list_worn_containers(character_id)
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
  Returns a list of all characters.

  ## Examples

      iex> list()
      [%Character{}, ...]

  """
  @spec list(list_of_ids :: [String.t(), ...]) :: [%__MODULE__{}]
  def list(list_of_ids) do
    base_no_skills_query()
    |> where([character], character.id in ^list_of_ids)
    |> Repo.all()
    |> preload()
  end

  @doc """
  Returns a list of characters all characters.

  ## Examples

      iex> list_all()
      [%Character{}, ...]

  """
  @spec list_all :: [%__MODULE__{}]
  def list_all do
    Repo.all(__MODULE__) |> preload()
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
    from(character in base_query_with_preload(),
      where: character.player_id == ^player_id
    )
    |> Repo.all()
    |> preload()
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
    |> preload()
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
    |> preload()
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
    |> preload()
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
      |> preload()
      |> (&{:ok, &1}).()
    end)
  end

  @spec get_by_name(String.t()) :: %__MODULE__{} | nil
  def get_by_name(name) do
    Repo.get_by(__MODULE__, name: name) |> preload()
  end

  @spec get_by_id(String.t()) :: %__MODULE__{} | nil
  def get_by_id(character_id) do
    Repo.get(__MODULE__, character_id) |> preload()
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
    Repo.one!(from(character in base_query_with_preload(), where: character.id == ^character_id))
    |> preload()
  end

  @spec list_known_shops(String.t()) :: [%__MODULE__{}]
  def list_known_shops(character_id) do
    character_shops =
      character_id
      |> Mud.Engine.CharactersShops.known_shop_ids_from_character_id_query()
      |> Shop.list_with_products_from_query()

    default_known_shops = Shop.list_with_products_from_permanently_explored_areas()

    Enum.concat([default_known_shops, character_shops])
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
    resp =
      character
      |> changeset(attrs)
      |> Repo.update()

    case resp do
      {:ok, character} ->
        {:ok, preload(character)}

      error ->
        error
    end
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

    character |> preload()
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
    |> preload()
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

  @spec sitting :: <<_::56>>
  def sitting, do: "sitting"

  @spec kneeling :: <<_::64>>
  def kneeling, do: "kneeling"

  @spec crouching :: <<_::72>>
  def crouching, do: "crouching"

  @spec prone :: <<_::40>>
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

  defp base_query_with_preload() do
    from(
      character in __MODULE__,
      join: bank in assoc(character, :bank),
      join: containers in assoc(character, :containers),
      join: physical_features in assoc(character, :physical_features),
      join: settings in assoc(character, :settings),
      join: slots in assoc(character, :slots),
      join: status in assoc(character, :status),
      join: wealth in assoc(character, :wealth),
      preload: [
        bank: bank,
        containers: containers,
        physical_features: physical_features,
        settings: settings,
        slots: slots,
        status: status,
        wealth: wealth
      ]
    )
  end

  defp preload(character) do
    Repo.preload(
      character,
      [:bank, :containers, :physical_features, :settings, :slots, :status, :wealth],
      force: true
    )
  end
end
