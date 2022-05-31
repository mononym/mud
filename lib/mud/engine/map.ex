defmodule Mud.Engine.Map do
  @moduledoc """
  A Map is a
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Mud.Repo
  alias Mud.Engine.{Area, Link, CharactersAreas}
  alias Mud.Engine.Map.Label
  import Ecto.Query
  require Protocol

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "maps" do
    @derive Jason.Encoder
    field(:description, :string)
    field(:name, :string)
    field(:key, :string)
    field(:view_size, :integer, default: 250)
    field(:grid_size, :integer, default: 10)

    has_many(:areas, Area)
    has_many(:labels, Label)

    timestamps()

    #
    # Things linked to the map
    #

    many_to_many(:characters, Mud.Engine.Character,
      join_through: Mud.Engine.CharactersMaps,
      on_replace: :raise
    )
  end

  @doc """
  Returns the list of maps.

  ## Examples

  iex> list_all()
  [%Map{}, ...]

  """
  @spec list_all :: [%__MODULE__{}]
  def list_all do
    Repo.all(
      from(
        map in __MODULE__,
        order_by: [desc: map.updated_at]
      )
    )
  end

  @doc """
  Determine whether or not a map has been visited before by a character
  """
  def has_been_explored?(new_map_id, character_id) do
    Mud.Repo.one(
      from(map in Mud.Engine.Map,
        left_join: character_map in Mud.Engine.CharactersMaps,
        on: character_map.map_id == map.id,
        where: map.id == ^new_map_id and character_map.character_id == ^character_id,
        select: count(map.id)
      )
    ) == 1
  end

  @doc """
  Mark a map as having been visited by a character
  """
  def mark_as_explored(map_id, character_id) do
    change(%Mud.Engine.CharactersMaps{}, %{
      character_id: character_id,
      map_id: map_id
    })
    |> Repo.insert()
  end

  @doc """
  Gets a single map.

  Raises `Ecto.NoResultsError` if the Map does not exist.

  ## Examples

      iex> get!("42")
      %Map{}

      iex> get!("24")
      ** (Ecto.NoResultsError)

  """
  def get!(id), do: Repo.get!(__MODULE__, id)

  @doc """
  Creates a map.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Map{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    result =
      %__MODULE__{}
      |> changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, map} ->
        {:ok, Repo.preload(map, :areas)}

      error ->
        error
    end
  end

  @doc """
  Returns a list of areas that are all related to a specific map.

  This method takes into account what areas a character actually knows about. This means the areas are either always
  known or they have been visited by the player, or the player has been otherwise made aware of the rooms.

  ## Examples

      iex> fetch_character_data(42)
      %{areas: [%Area{}], links: [%Link{}]}

  """
  def fetch_character_data(character_id, map_id) do
    # search the map for the areas that are either public knowledge or that the character has visited before.
    # this means there may be some areas in the map which the player does not know about, which means there may be
    # internal links which go between rooms where one room is known but the other is not. These links should be
    # returned so that in the front end the map can be properly constructed to show a partial/unexplored link.

    # All rooms character knows about or are public
    known_areas_query = base_known_character_areas_query(character_id, map_id)

    known_areas = known_areas_query |> Repo.all() |> Repo.preload([:flags])

    known_area_ids = Enum.map(known_areas, & &1.id)

    known_links = base_links_from_areas_query(known_areas_query) |> Repo.all()

    external_ids =
      known_links
      |> Stream.flat_map(&[&1.to_id, &1.from_id])
      |> Stream.uniq()
      |> Enum.filter(&(&1 not in known_area_ids))

    external_areas =
      Repo.all(
        from(
          area in Area,
          where: area.id in ^external_ids
        )
      )

    all_area_ids = Enum.concat(known_area_ids, external_ids)

    explored_character_areas =
      Repo.all(
        from(
          character_area in CharactersAreas,
          where:
            character_area.character_id == ^character_id and
              character_area.area_id in ^all_area_ids,
          select: character_area.area_id
        )
      )

    %{
      areas: Enum.concat([external_areas, known_areas]) |> Repo.preload([:flags]),
      links: known_links |> Repo.preload([:closable, :flags]),
      explored_areas: explored_character_areas
    }
  end

  @doc """
  Returns a list of areas that are all related to a specific map.

  This includes areas that are linked to the areas that actually belong to the map

  ## Examples

      iex> fetch_data(42)
      %{areas: [%Area{}], links: [%Link{}]}

  """
  def fetch_data(map_id) do
    internal_areas =
      Repo.all(
        from(
          area in Area,
          where: area.map_id == ^map_id
        )
      )

    internal_ids = Enum.map(internal_areas, & &1.id)

    links =
      Repo.all(
        from(
          link in Link,
          where: link.to_id in ^internal_ids or link.from_id in ^internal_ids
        )
      )

    external_ids =
      links
      |> Stream.flat_map(&[&1.to_id, &1.from_id])
      |> Stream.uniq()
      |> Enum.filter(&(&1 not in internal_ids))

    external_areas =
      Repo.all(
        from(
          area in Area,
          where: area.id in ^external_ids
        )
      )

    labels = Label.get_map_labels(map_id)

    %{
      areas:
        Enum.concat([external_areas, internal_areas])
        |> Repo.preload([:flags, shops: [:products]]),
      labels: labels,
      links: links |> Repo.preload([:closable, :flags])
    }
  end

  @doc """
  Updates a map.

  ## Examples

      iex> update(map, %{field: new_value})
      {:ok, %Map{}}

      iex> update(map, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%__MODULE__{} = map, attrs) do
    map
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a map.

  ## Examples

      iex> delete(map)
      {:ok, %Map{}}

      iex> delete(map)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%__MODULE__{} = map) do
    Repo.delete(map)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking map changes.

  ## Examples

      iex> changeset(map)
      %Ecto.Changeset{data: %Map{}}

  """
  def changeset(%__MODULE__{} = map, attrs \\ %{}) do
    map
    |> cast(attrs, [
      :name,
      :description,
      :view_size,
      :grid_size,
      :key
    ])
    |> validate_required([
      :name,
      :description,
      :view_size,
      :grid_size,
      :key
    ])
  end

  defp base_known_character_areas_query(character_id, map_id) do
    from(
      area in Area,
      left_join: character_area in Mud.Engine.CharactersAreas,
      on: character_area.area_id == area.id,
      inner_join: area_flags in Area.Flags,
      on: area.id == area_flags.area_id,
      where: area.map_id == ^map_id and character_area.character_id == ^character_id
    )
  end

  defp base_links_from_areas_query(areas_query) do
    areas_ids_query = from(area in areas_query, select: area.id)

    from(
      link in Link.base_query_with_preload(),
      where: link.to_id in subquery(areas_ids_query) or link.from_id in subquery(areas_ids_query)
    )
  end
end
