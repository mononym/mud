defmodule Mud.Engine.Area do
  use Mud.Schema
  import Ecto.Changeset
  alias Mud.Repo
  alias Mud.Engine.{Character, CharactersAreas, Link, Item, Message}
  alias Mud.Engine.Message.StoryOutput
  alias Mud.Engine
  alias Mud.Engine.Area.{Flags}
  import Ecto.Query
  require Logger

  @derive {Jason.Encoder,
           only: [
             :id,
             :description,
             :name,
             :map_x,
             :map_y,
             :map_size,
             :map_corners,
             :map_id,
             :border_width,
             :border_color,
             :color,
             :inserted_at,
             :updated_at
           ]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "areas" do
    has_one(:flags, Flags)

    field(:description, :string)
    field(:name, :string)

    ##
    ##
    # Map stuff
    ##
    ##

    field(:map_x, :integer, default: 0)
    field(:map_y, :integer, default: 0)
    field(:map_size, :integer, default: 21)
    field(:map_corners, :integer, default: 5)
    field(:permanently_explored, :boolean, default: false)

    belongs_to(:map, Map, type: :binary_id)

    has_many(:characters, Character)
    has_many(:to_links, Link, foreign_key: :to_id)
    has_many(:from_links, Link, foreign_key: :from_id)

    field(:border_width, :integer, default: 2)
    field(:border_color, :string, default: "#FFFFFF")
    field(:color, :string, default: "#696969")

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
    |> Repo.preload([:flags])
  end

  @doc """
  Returns a list of areas that all belong to a specific map.

  ## Examples

      iex> list_by_map(42)
      [%__MODULE__{}, ...]

  """
  def list_by_map(map_id, include_linked) do
    if include_linked do
      internal_areas =
        Repo.all(
          from(
            area in __MODULE__,
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
            area in __MODULE__,
            where: area.id in ^external_ids
          )
        )

      Stream.concat([external_areas, internal_areas])
      |> Enum.sort_by(& &1.updated_at, &(&2 <= &1))
      |> Repo.preload([:flags])
    else
      Repo.all(
        from(
          area in __MODULE__,
          where: area.map_id == ^map_id,
          order_by: [desc: area.updated_at]
        )
      )
      |> Repo.preload([:flags])
    end
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
  def get!(id), do: Repo.get!(__MODULE__, id) |> Repo.preload([:flags])

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
    {:ok, area} =
      %__MODULE__{}
      |> changeset(attrs)
      |> Repo.insert()

    # Set up stuff for area
    Flags.create(Map.put(Map.get(attrs, :flags, %{}), :area_id, area.id))

    area = Repo.preload(area, [:flags])

    {:ok, area}
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
    IO.inspect(area)
    IO.inspect(attrs)

    if Map.has_key?(attrs, "flags") do
      Flags.update!(area.flags, attrs["flags"]) |> IO.inspect(label: :flagupdate)
    end

    res =
      area
      |> changeset(attrs)
      |> Repo.update()

    case res do
      {:ok, result} ->
        {:ok, Repo.preload(result, [:flags], force: true)} |> IO.inspect()

      error ->
        error
    end
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

  @doc """
  Determine whether or not an area has been visited before by a character
  """
  def has_been_explored?(new_area_id, character_id) do
    Mud.Repo.one(
      from(area in Mud.Engine.Area,
        left_join: character_area in Mud.Engine.CharactersAreas,
        on: character_area.area_id == area.id,
        where:
          area.id == ^new_area_id and
            (character_area.character_id == ^character_id or area.permanently_explored),
        select: count(area.id)
      )
    ) == 1
  end

  def mark_as_explored(area_id, character_id) do
    change(%Mud.Engine.CharactersAreas{}, %{
      character_id: character_id,
      area_id: area_id
    })
    |> Repo.insert()
  end

  @doc """
  Given a specific area id, find and list all of the areas linked to it which a character has not explored yet.
  """
  def list_unexplored_areas_linked_to_area(area_id, character_id) do
    # from area
    # find all links
    # find all areas on other side of links
    # return only areas which are not explored

    # area by id
    # links from area where from area is area.id select to.id
    # areas on other side of link subquery where unexplored
    to_area_ids_query = Link.link_to_area_ids_from_area_ids([area_id])

    explored_ids =
      CharactersAreas.explored_ids_from_area_ids_subquery(to_area_ids_query, character_id)

    from(area in base_area_query(),
      where:
        area.id in subquery(to_area_ids_query) and area.permanently_explored == false and
          area.id not in subquery(explored_ids)
    )
    |> Repo.all()
    |> Repo.preload([:flags])

    # Mud.Repo.one(
    #   from(area in Mud.Engine.Area,
    #     left_join: character_area in Mud.Engine.CharactersAreas,
    #     on: character_area.area_id == area.id,
    #     where:
    #       area.id == ^new_area_id and
    #         (character_area.character_id == ^character_id or area.permanently_explored),
    #     select: count(area.id)
    #   )
    # ) == 1
  end

  #
  # Private Functions
  #

  @doc false
  @spec changeset(area :: %__MODULE__{}, attributes :: map()) :: %Ecto.Changeset{}
  defp changeset(area, attrs) do
    area
    |> cast(attrs, [
      :name,
      :description,
      :map_id,
      :map_x,
      :map_y,
      :map_size,
      :map_corners,
      :border_color,
      :border_width,
      :color,
      :permanently_explored
    ])
    |> validate_required([
      :name,
      :description,
      :map_id,
      :map_x,
      :map_y,
      :map_size,
      :map_corners,
      :border_width,
      :border_color,
      :color
    ])
  end

  # TODO: Revisit this and streamline it. Only hit DB once and pull back more data
  @spec long_description_to_story_output(
          area_id :: String.t() | %__MODULE__{},
          character :: Character.t()
        ) ::
          description :: StoryOutput.t()
  def long_description_to_story_output(area = %__MODULE__{}, character) do
    Logger.debug(
      "Generating long description for area `#{area.id}` and character `#{character.id}`"
    )

    newOutput = Message.new_story_output(character.id)

    newOutput
    |> build_area_name(area)
    |> build_area_desc(area)
    |> maybe_build_things_of_interest(area)
    |> maybe_build_on_ground(area)
    |> maybe_build_hostiles(area)
    |> maybe_build_denizens(area)
    |> maybe_build_also_present(area, character)
    |> maybe_build_exits(area)
  end

  def long_description_to_story_output(area_id, character) do
    Logger.debug(
      "Generating long description for area `#{area_id}` and character `#{character.id}`"
    )

    area = get!(area_id)
    long_description_to_story_output(area, character)
  end

  #
  #
  # Area Queries for use internally and externally
  #
  #

  @doc """
  Basic query for finding areas. Nothing fancy, no preloads.
  """
  def base_area_query do
    from(area in __MODULE__)
  end

  @doc """
  Extends `base_area_query` by filtering out areas which don't exactly match an id
  """
  def area_by_id_query(id) do
    from(area in base_area_query(),
      where: area.id == ^id
    )
  end

  @doc """
  Extends `base_area_query` by filtering out areas which don't exactly match a name
  """
  def area_by_exact_name_query(name) do
    from(area in base_area_query(),
      where: area.name == ^name
    )
  end

  @doc """
  Extends `base_area_query` by filtering out areas which don't match a like query for the name
  """
  def area_by_like_name_query(name) do
    from(area in base_area_query(),
      where: like(area.name, ^name)
    )
  end

  @doc """
  Extends `base_area_query` by only returning areas which are unexplored
  """
  def area_unexplored_query() do
    from(area in base_area_query(),
      where: area
    )
  end

  #
  #
  # Private/Helper functions
  #
  #

  defp build_area_name(story_output, area) do
    Message.append_text(story_output, "[#{area.name}]\n", "area_name")
  end

  defp build_area_desc(story_output, area) do
    Message.append_text(story_output, "#{area.description}\n", "area_description")
  end

  defp maybe_build_hostiles(text, _area) do
    # <> "{{hostiles}}Hostiles: #{player_characters}{{/hostiles}}\n"
    text
  end

  defp maybe_build_denizens(text, _area) do
    # <> "{{denizens}}Denizens: #{player_characters}{{/denizens}}\n"
    text
  end

  defp maybe_build_things_of_interest(story_output, area) do
    things_of_interest =
      area.id
      |> Item.list_scenery_in_area()
      |> Enum.filter(&(&1.flags.hidden != true))

    if things_of_interest == [] do
      story_output
    else
      story_output = Message.append_text(story_output, "Things of Interest: ", "toi_label")

      things_of_interest
      |> Enum.reduce(
        story_output,
        fn item, message ->
          message
          |> Message.append_text(item.description.short, Engine.Util.get_item_type(item))
          |> Message.append_text(", ", "base")
        end
      )
      |> Message.drop_last_text()
      |> Message.append_text("\n", "base")
    end
  end

  defp maybe_build_on_ground(story_output, area) do
    items_on_ground = Item.list_on_ground(area.id)

    if items_on_ground == [] do
      story_output
    else
      story_output = Message.append_text(story_output, "On Ground: ", "on_ground_label")

      items_on_ground
      |> Enum.reduce(
        story_output,
        fn item, message ->
          message
          |> Message.append_text(item.description.short, Engine.Util.get_item_type(item))
          |> Message.append_text(", ", "base")
        end
      )
      |> Message.drop_last_text()
      |> Message.append_text("\n", "base")
    end
  end

  defp maybe_build_also_present(story_output, area, character) do
    also_present =
      Mud.Engine.Character.list_active_in_areas(area.id)
      # filter out self
      |> Enum.filter(fn char ->
        char.id != character.id
      end)
      |> Enum.sort(&(&1.name <= &2.name))

    if also_present == [] do
      story_output
    else
      story_output = Message.append_text(story_output, "Also Present: ", "character_label")

      also_present
      |> Enum.reduce(
        story_output,
        fn character, message ->
          message
          |> Message.append_text(character.name, "character")
          |> Message.append_text(", ", "base")
        end
      )
      |> Message.drop_last_text()
      |> Message.append_text("\n", "base")
    end
  end

  defp maybe_build_exits(story_output, area) do
    links = Mud.Engine.Link.list_obvious_exits_in_area(area.id)

    if links == [] do
      story_output
    else
      story_output = Message.append_text(story_output, "Obvious Exits: ", "exit_label")

      links
      |> Enum.reduce(
        story_output,
        fn link, message ->
          desc =
            if link.flags.closable do
              "#{link.short_description} (#{
                if link.closable.open do
                  "open"
                else
                  "closed"
                end
              })"
            else
              link.short_description
            end

          message
          |> Message.append_text(desc, Engine.Util.get_link_type(link))
          |> Message.append_text(", ", "base")
        end
      )
      |> Message.drop_last_text()
      |> Message.append_text("\n", "base")
    end
  end
end
