defmodule Mud.Engine.Area do
  use Mud.Schema
  import Ecto.Changeset
  alias Mud.Repo
  alias Mud.Engine.{Character, Link, Item, Map, Message}
  alias Mud.Engine.Message.StoryOutput
  import Ecto.Query
  require Logger

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "areas" do
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

    belongs_to(:map, Map, type: :binary_id)

    has_many(:characters, Character)
    has_many(:items, Item)
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
    else
      Repo.all(
        from(
          area in __MODULE__,
          where: area.map_id == ^map_id,
          order_by: [desc: area.updated_at]
        )
      )
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
      :color
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
  @spec long_description(area_id :: String.t(), character :: Character.t()) ::
          description :: StoryOutput.t()
  def long_description(area_id, character) do
    Logger.debug(
      "Generating long description for area `#{area_id}` and character `#{character.id}`"
    )

    area = get!(area_id)
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
      |> Item.list_visible_scenery_in_area()
      |> Stream.map(& &1.short_description)
      |> Enum.sort()
      |> Enum.join(", ")

    if things_of_interest == "" do
      story_output
    else
      Message.append_text(story_output, "Things of Interest: #{things_of_interest}\n", "text")
    end
  end

  defp maybe_build_on_ground(story_output, area) do
    on_ground =
      Item.list_in_area(area.id)
      |> Stream.filter(&(!&1.is_scenery))
      |> Stream.map(& &1.short_description)
      |> Enum.sort()
      |> Enum.join(", ")

    if on_ground == "" do
      story_output
    else
      Message.append_text(story_output, "On Ground: #{on_ground}\n", "text")
    end
  end

  defp maybe_build_also_present(story_output, area, character_id) do
    also_present = build_player_characters_string(area.id, character_id)

    if also_present == "" do
      story_output
    else
      Message.append_text(story_output, "Also Present: #{also_present}\n", "text")
    end
  end

  defp maybe_build_obvious_exits(story_output, area) do
    obvious_exits = build_obvious_exits_string(area.id)

    if obvious_exits == "" do
      story_output
    else
      Message.append_text(story_output, "Obvious Exits: #{obvious_exits}\n", "text")
    end
  end

  defp build_obvious_exits_string(area_id) do
    links = Mud.Engine.Link.list_obvious_exits_in_area(area_id)
    Logger.debug(links)

    links
    |> Stream.map(fn link ->
      link.short_description
    end)
    |> Enum.sort()
    |> Enum.join(", ")
  end

  defp maybe_build_exits(story_output, area) do
    links = Mud.Engine.Link.list_obvious_exits_in_area(area.id)
    Logger.debug(links)

    if links == [] do
      story_output
    else
      story_output = Message.append_text(story_output, "Obvious Exits: ", "exit_label")

      links
      |> Enum.reduce(
        story_output,
        fn link, message ->
          message
          |> Message.append_text(link.short_description, "exit")
          |> Message.append_text(", ", "base")
        end
      )
      |> Message.drop_last_text()
      |> Message.append_text("\n", "base")
    end
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
