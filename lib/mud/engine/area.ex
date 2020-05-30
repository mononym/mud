defmodule Mud.Engine.Area do
  use Mud.Schema
  import Ecto.Changeset
  alias Mud.Repo
  alias Mud.Engine.{Character, Link, Item}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "areas" do
    field(:description, :string)
    field(:name, :string)

    has_many(:characters, Character)
    has_many(:items, Item)
    has_many(:to_links, Link, foreign_key: :to_id)
    has_many(:from_links, Link, foreign_key: :from_id)

    timestamps()
  end

  @doc """
  Returns the list of areas.

  ## Examples

      iex> list_all()
      [%__MODULE__{}, ...]

  """
  @spec list_all() :: [%__MODULE__{}]
  def list_all do
    Repo.all(__MODULE__)
  end

  @doc """
  Gets a single area.

  Raises `Ecto.NoResultsError` if the Area does not exist.

  ## Examples

      iex> get_area!("123")
      %__MODULE__{}

      iex> get_area!("456")
      ** (Ecto.NoResultsError)

  """
  @spec get_area!(id :: String.t()) :: %__MODULE__{}
  def get_area!(id), do: Repo.get!(__MODULE__, id)

  @doc """
  Creates a area.

  ## Examples

      iex> create_area(%{field: value})
      {:ok, %__MODULE__{}}

      iex> create_area(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_area(attributes :: map()) :: {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
  def create_area(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a area.

  ## Examples

      iex> update_area(area, %{field: new_value})
      {:ok, %__MODULE__{}}

      iex> update_area(area, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_area(area :: %__MODULE__{}, attributes :: map()) ::
          {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
  def update_area(area, attrs) do
    area
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a area.

  ## Examples

      iex> delete_area(area)
      {:ok, %__MODULE__{}}

      iex> delete_area(area)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_area(area :: %__MODULE__{}) :: {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
  def delete_area(area) do
    Repo.delete(area)
  end

  #
  # Private Functions
  #

  @doc false
  @spec changeset(area :: %__MODULE__{}, attributes :: map()) :: %Ecto.Changeset{}
  defp changeset(area, attrs) do
    area
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end

  # TODO: Revisit this and streamline it. Only hit DB once and pull back more data
  @spec describe_look(area_id :: String.t(), character :: Character.t()) ::
          description :: String.t()
  def describe_look(area_id, character) do
    area = get_area!(area_id)

    build_area_name(area)
    |> build_area_desc(area)
    |> maybe_build_things_of_interest(area, character)
    |> maybe_build_on_ground(area, character)
    |> maybe_build_hostiles(area)
    |> maybe_build_denizens(area)
    |> maybe_build_also_present(area, character)
    |> maybe_build_obvious_exits(area)
  end

  defp build_area_name(area) do
    "{{area-name}}[#{area.name}]{{/area-name}}\n"
  end

  defp build_area_desc(text, area) do
    text <> "{{area-description}}#{area.description}{{/area-description}}\n"
  end

  defp maybe_build_hostiles(text, _area) do
    # <> "{{hostiles}}Hostiles: #{player_characters}{{/hostiles}}\n"
    text
  end

  defp maybe_build_denizens(text, _area) do
    # <> "{{denizens}}Denizens: #{player_characters}{{/denizens}}\n"
    text
  end

  defp maybe_build_things_of_interest(text, area, looking_character) do
    things_of_interest =
      area.id
      |> Item.list_visible_scenery_in_area()
      |> Stream.map(fn item ->
        describe_thing(item, looking_character.id)
      end)
      |> Enum.sort()
      |> Enum.join(", ")

    if things_of_interest == "" do
      text
    else
      text <>
        "{{things-of-interest}}Things of Interest: #{things_of_interest}{{/things-of-interest}}\n"
    end
  end

  defp maybe_build_on_ground(text, area, looking_character) do
    on_ground =
      Item.list_in_area(area.id)
      |> Stream.filter(&(!&1.is_scenery))
      |> Stream.map(fn item ->
        describe_thing(item, looking_character.id)
      end)
      |> Enum.sort()
      |> Enum.join(", ")

    if on_ground == "" do
      text
    else
      text <> "{{on-ground}}On Ground: #{on_ground}{{/on-ground}}\n"
    end
  end

  defp maybe_build_also_present(text, area, character_id) do
    also_present = build_player_characters_string(area.id, character_id)

    if also_present == "" do
      text
    else
      text <> "{{also-present}}Also Present: #{also_present}{{/also-present}}\n"
    end
  end

  defp maybe_build_obvious_exits(text, area) do
    obvious_exits = build_obvious_exits_string(area.id)

    if obvious_exits == "" do
      text
    else
      text <> "{{obvious-exits}}Obvious Exits: #{obvious_exits}{{/obvious-exits}}\n"
    end
  end

  defp build_obvious_exits_string(area_id) do
    Mud.Engine.Link.list_obvious_exits_in_area(area_id)
    |> Enum.map(fn link ->
      link.text
    end)
    |> Enum.sort()
    |> Enum.join(", ")
  end

  # Character list should not contain the character the look is being performed for
  defp build_player_characters_string(area_id, looking_character) do
    Mud.Engine.Character.list_active_in_areas(area_id)
    # filter out self
    |> Enum.filter(fn char ->
      char.id != looking_character.id
    end)
    |> Enum.sort(&(&1.name <= &2.name))
    |> Enum.map(&Character.describe_room_glance(&1, looking_character))
    |> Enum.join(", ")
  end

  defp describe_thing(item = %Item{}, looking_character) do
    Item.describe_glance(item, looking_character)
  end

  defp describe_thing(character = %Character{}, looking_character) do
    Character.describe_glance(character, looking_character)
  end

  defp describe_thing(link = %Link{}, looking_character) do
    Link.describe_glance(link, looking_character)
  end
end
