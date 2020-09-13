defmodule Mud.Engine.Area do
  use Mud.Schema
  import Ecto.Changeset
  alias Mud.Repo
  alias Mud.Engine.{Character, Link, Instance, Item, Map, Region}
  import Ecto.Query

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "areas" do
    field(:description, :string)
    field(:name, :string)

    ##
    ##
    # Map stuff
    ##
    ##

    field(:map_x, :integer)
    field(:map_y, :integer)
    field(:map_size, :integer)

    belongs_to(:map, Map, type: :binary_id)
    belongs_to(:region, Region, type: :binary_id)
    belongs_to(:instance, Instance, type: :binary_id)

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

  @spec list_in_region(region :: struct() | String.t()) :: [%__MODULE__{}]
  def list_in_region(region) when is_struct(region) do
    list_in_region(region.id)
  end

  def list_in_region(region_id) do
    Repo.all(
      from(
        area in __MODULE__,
        where: area.region_id == ^region_id
      )
    )
  end

  @doc """
  Returns a list of areas that all belong to a specific map.

  ## Examples

      iex> list_by_map(42)
      [%__MODULE__{}, ...]

  """
  def list_by_map(map_id) do
    Repo.all(
      from(
        area in __MODULE__,
        where: area.map_id == ^map_id
      )
    )
  end

  @doc """
  Gets a single area.

  Raises `Ecto.NoResultsError` if the Area does not exist.

  ## Examples

      iex> get!("123")
      %__MODULE__{}

      iex> get!("456")w
      ** (Ecto.NoResultsError)

  """
  @spec get!(id :: String.t()) :: %__MODULE__{}
  def get!(id), do: Repo.get!(__MODULE__, id)

  @spec get!(Ecto.Multi.t(), atom(), String.t()) :: Ecto.Multi.t()
  def get!(multi, name, area_id) do
    Ecto.Multi.run(multi, name, fn repo, _changes ->
      {:ok, repo.get!(__MODULE__, area_id)}
    end)
  end

  @doc """
  Creates a area.

  ## Examples

      iex> create(%{field: value})
      {:ok, %__MODULE__{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create(attributes :: map()) :: {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a area.

  ## Examples

      iex> update(area, %{field: new_value})
      {:ok, %__MODULE__{}}

      iex> update(area, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update(area :: %__MODULE__{}, attributes :: map()) ::
          {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
  def update(area, attrs) do
    area
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a area.

  ## Examples

      iex> delete(area)
      {:ok, %__MODULE__{}}

      iex> delete(area)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete(area :: %__MODULE__{}) :: {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
  def delete(area) do
    Repo.delete(area)
  end

  #
  # Private Functions
  #

  @doc false
  @spec changeset(area :: %__MODULE__{}, attributes :: map()) :: %Ecto.Changeset{}
  defp changeset(area, attrs) do
    area
    |> cast(attrs, [:name, :description, :map_id, :instance_id, :region_id])
    |> validate_required([:name, :description, :map_id])
  end

  # TODO: Revisit this and streamline it. Only hit DB once and pull back more data
  @spec long_description(area_id :: String.t(), character :: Character.t()) ::
          description :: String.t()
  def long_description(area_id, character) do
    area = get!(area_id)

    build_area_name(area)
    |> build_area_desc(area)
    |> maybe_build_things_of_interest(area)
    |> maybe_build_on_ground(area)
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

  defp maybe_build_things_of_interest(text, area) do
    things_of_interest =
      area.id
      |> Item.list_visible_scenery_in_area()
      |> Stream.map(& &1.short_description)
      |> Enum.sort()
      |> Enum.join(", ")

    if things_of_interest == "" do
      text
    else
      text <>
        "{{things-of-interest}}Things of Interest: #{things_of_interest}{{/things-of-interest}}\n"
    end
  end

  defp maybe_build_on_ground(text, area) do
    on_ground =
      Item.list_in_area(area.id)
      |> Stream.filter(&(!&1.is_scenery))
      |> Stream.map(& &1.short_description)
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
    |> Stream.map(fn link ->
      link.short_description
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
    |> Enum.map(&Character.describe_room_glance/1)
    |> Enum.join(", ")
  end
end
