defmodule Mud.Engine do
  @moduledoc """
  The Engine context.
  """

  import Ecto.Query, warn: false
  alias Mud.Repo

  alias Mud.Engine.Area
  alias Mud.Engine.Character

  require Logger

  @doc """
  Returns the list of areas.

  ## Examples

      iex> list_areas()
      [%Area{}, ...]

  """
  def list_areas do
    Repo.all(Area)
  end

  @doc """
  Gets a single area.

  Raises `Ecto.NoResultsError` if the Area does not exist.

  ## Examples

      iex> get_area!(123)
      %Area{}

      iex> get_area!(456)
      ** (Ecto.NoResultsError)

  """
  def get_area!(id), do: Repo.get!(Area, id)

  @doc """
  Creates a area.

  ## Examples

      iex> create_area(%{field: value})
      {:ok, %Area{}}

      iex> create_area(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_area(attrs \\ %{}) do
    %Area{}
    |> Area.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a area.

  ## Examples

      iex> update_area(area, %{field: new_value})
      {:ok, %Area{}}

      iex> update_area(area, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_area(%Area{} = area, attrs) do
    area
    |> Area.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a area.

  ## Examples

      iex> delete_area(area)
      {:ok, %Area{}}

      iex> delete_area(area)
      {:error, %Ecto.Changeset{}}

  """
  def delete_area(%Area{} = area) do
    Repo.delete(area)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking area changes.

  ## Examples

      iex> change_area(area)
      %Ecto.Changeset{source: %Area{}}

  """
  def change_area(%Area{} = area) do
    Area.changeset(area, %{})
  end

  alias Mud.Engine.Link

  @doc """
  Returns the list of links.

  ## Examples

      iex> list_links()
      [%Link{}, ...]

  """
  def list_links do
    Repo.all(Link)
  end

  @doc """
  Returns the list of links "from" a room where the type of the link is "obvious".

  ## Examples

      iex> list_obvious_exits("valid room id")
      [%Link{}, ...]

  """
  def list_obvious_exits(area_id) do
    Repo.all(
      from(link in Link,
        where: link.from_id == ^area_id and link.type == ^"obvious"
      )
    )
  end

  @doc """
  Returns a single.

  ## Examples

      iex> find_obvious_exit_in_character_location("valid character id", "valid direction")
      %Area{}

      iex> find_obvious_exit_in_character_location("valid character id", "invalid direction")
      nil

  """
  def find_obvious_exit_in_character_location(character_id, direction) do
    Repo.one(
      from(link in Link,
        join: area in Area,
        on: area.id == link.from_id,
        join: character in Character,
        on: area.id == character.location_id,
        where:
          character.id == ^character_id and link.type == ^"obvious" and
            link.departure_direction == ^direction,
        select: link
      )
    )
  end

  @doc """
  Gets a single link.

  Raises `Ecto.NoResultsError` if the Link does not exist.

  ## Examples

      iex> get_link!(123)
      %Link{}

      iex> get_link!(456)
      ** (Ecto.NoResultsError)

  """
  def get_link!(id), do: Repo.get!(Link, id)

  @doc """
  Creates a link.

  ## Examples

      iex> create_link(%{field: value})
      {:ok, %Link{}}

      iex> create_link(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_link(attrs \\ %{}) do
    %Link{}
    |> Link.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a link.

  ## Examples

      iex> update_link(link, %{field: new_value})
      {:ok, %Link{}}

      iex> update_link(link, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_link(%Link{} = link, attrs) do
    link
    |> Link.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a link.

  ## Examples

      iex> delete_link(link)
      {:ok, %Link{}}

      iex> delete_link(link)
      {:error, %Ecto.Changeset{}}

  """
  def delete_link(%Link{} = link) do
    Repo.delete(link)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking link changes.

  ## Examples

      iex> change_link(link)
      %Ecto.Changeset{source: %Link{}}

  """
  def change_link(%Link{} = link) do
    Link.changeset(link, %{})
  end

  alias Mud.Engine.Character

  @doc """
  Returns the list of characters.

  ## Examples

      iex> list_characters()
      [%Character{}, ...]

  """
  def list_characters do
    Repo.all(Character)
  end

  @doc """
  Returns the list of characters that are both active and in the given location(s).

  ## Examples

      iex> list_active_characters_in_areas(42)
      [%Character{}, ...]

      iex> list_active_characters_in_areas([42, 24])
      [%Character{}, ...]

  """
  def list_active_characters_in_areas(area_ids) do
    Repo.all(
      from(
        character in Character,
        join: attributes in assoc(character, :attributes),
        where: character.location_id in ^List.wrap(area_ids) and character.active == true,
        preload: [attributes: attributes]
      )
    )
  end

  @doc """
  Gets a single character.

  Raises `Ecto.NoResultsError` if the Character does not exist.

  ## Examples

      iex> get_character!(123)
      %Character{}

      iex> get_character!(456)
      ** (Ecto.NoResultsError)

  """
  def get_character!(id) do
    Repo.one!(
      from(
        character in Character,
        join: attributes in assoc(character, :attributes),
        where: character.id == ^id,
        preload: [attributes: attributes]
      )
    )
  end

  @doc """
  Creates a character.

  ## Examples

      iex> create_character(%{field: value})
      {:ok, %Character{}}

      iex> create_character(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_character(attrs \\ %{}) do
    # For POC set character's initial room as room #1
    attrs = Map.put(attrs, "location", 1)

    result =
      %Character{}
      |> Character.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, character} ->
        Ecto.build_assoc(character, :attributes, %{})
        |> Repo.insert!()

        {:ok, character}

      error ->
        error
    end
  end

  @doc """
  Updates a character.

  ## Examples

      iex> update_character(character, %{field: new_value})
      {:ok, %Character{}}

      iex> update_character(character, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_character(%Character{} = character, attrs) do
    character
    |> Character.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a character.

  ## Examples

      iex> delete_character(character)
      {:ok, %Character{}}

      iex> delete_character(character)
      {:error, %Ecto.Changeset{}}

  """
  def delete_character(%Character{} = character) do
    Repo.delete(character)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking character changes.

  ## Examples

      iex> change_character(character)
      %Ecto.Changeset{source: %Character{}}

  """
  def change_character(%Character{} = character) do
    Character.changeset(character, %{})
  end

  def start_character_session(character_id) do
    spec = {Mud.Engine.Session, %{character_id: character_id}}

    result = DynamicSupervisor.start_child(Mud.Engine.CharacterSessionSupervisor, spec)

    Logger.debug("start_character_session result: #{inspect(result)}")

    :ok
  end

  def subscribe_to_character_session(character_id) do
    Mud.Engine.Session.subscribe(character_id)
  end

  def get_character_history(character_id) do
    Mud.Engine.Session.get_history(character_id)
  end

  @doc """
  Cast a `%Mud.Engine.Message{}` to a character session process.
  """
  def cast_message_to_character_session(message) do
    Mud.Engine.Session.cast_message(message.character_id, message)
  end

  def get_character_session_history(character_id) do
    Mud.Engine.Session.get_history(character_id)
  end

  alias Mud.Engine.Object

  @doc """
  Returns the list of objects.

  ## Examples

      iex> list_objects()
      [%Object{}, ...]

  """
  def list_objects do
    Repo.all(Object)
  end

  @doc """
  Gets a single object.

  Raises `Ecto.NoResultsError` if the Object does not exist.

  ## Examples

      iex> get_object!(123)
      %Object{}

      iex> get_object!(456)
      ** (Ecto.NoResultsError)

  """
  def get_object!(id), do: Repo.get!(Object, id)

  @doc """
  Creates a object.

  ## Examples

      iex> create_object(%{field: value})
      {:ok, %Object{}}

      iex> create_object(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_object(attrs \\ %{}) do
    %Object{}
    |> Object.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a object.

  ## Examples

      iex> update_object(object, %{field: new_value})
      {:ok, %Object{}}

      iex> update_object(object, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_object(%Object{} = object, attrs) do
    object
    |> Object.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a object.

  ## Examples

      iex> delete_object(object)
      {:ok, %Object{}}

      iex> delete_object(object)
      {:error, %Ecto.Changeset{}}

  """
  def delete_object(%Object{} = object) do
    Repo.delete(object)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking object changes.

  ## Examples

      iex> change_object(object)
      %Ecto.Changeset{source: %Object{}}

  """
  def change_object(%Object{} = object) do
    Object.changeset(object, %{})
  end

  alias Mud.Engine.Component.Location

  @doc """
  Returns the list of location_components.

  ## Examples

      iex> list_location_components()
      [%Location{}, ...]

  """
  def list_location_components do
    Repo.all(Location)
  end

  @doc """
  Gets a single location.

  Raises `Ecto.NoResultsError` if the Location does not exist.

  ## Examples

      iex> get_location!(123)
      %Location{}

      iex> get_location!(456)
      ** (Ecto.NoResultsError)

  """
  def get_location!(id), do: Repo.get!(Location, id)

  @doc """
  Creates a location.

  ## Examples

      iex> create_location(%{field: value})
      {:ok, %Location{}}

      iex> create_location(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_location(attrs \\ %{}) do
    %Location{}
    |> Location.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a location.

  ## Examples

      iex> update_location(location, %{field: new_value})
      {:ok, %Location{}}

      iex> update_location(location, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_location(%Location{} = location, attrs) do
    location
    |> Location.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a location.

  ## Examples

      iex> delete_location(location)
      {:ok, %Location{}}

      iex> delete_location(location)
      {:error, %Ecto.Changeset{}}

  """
  def delete_location(%Location{} = location) do
    Repo.delete(location)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking location changes.

  ## Examples

      iex> change_location(location)
      %Ecto.Changeset{source: %Location{}}

  """
  def change_location(%Location{} = location) do
    Location.changeset(location, %{})
  end

  alias Mud.Engine.Component.Description

  @doc """
  Returns the list of description_components.

  ## Examples

      iex> list_description_components()
      [%Description{}, ...]

  """
  def list_description_components do
    Repo.all(Description)
  end

  @doc """
  Gets a single description.

  Raises `Ecto.NoResultsError` if the Description does not exist.

  ## Examples

      iex> get_description!(123)
      %Description{}

      iex> get_description!(456)
      ** (Ecto.NoResultsError)

  """
  def get_description!(id), do: Repo.get!(Description, id)

  @doc """
  Creates a description.

  ## Examples

      iex> create_description(%{field: value})
      {:ok, %Description{}}

      iex> create_description(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_description(attrs \\ %{}) do
    %Description{}
    |> Description.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a description.

  ## Examples

      iex> update_description(description, %{field: new_value})
      {:ok, %Description{}}

      iex> update_description(description, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_description(%Description{} = description, attrs) do
    description
    |> Description.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a description.

  ## Examples

      iex> delete_description(description)
      {:ok, %Description{}}

      iex> delete_description(description)
      {:error, %Ecto.Changeset{}}

  """
  def delete_description(%Description{} = description) do
    Repo.delete(description)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking description changes.

  ## Examples

      iex> change_description(description)
      %Ecto.Changeset{source: %Description{}}

  """
  def change_description(%Description{} = description) do
    Description.changeset(description, %{})
  end
end
