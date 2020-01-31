defmodule Mud.Engine do
  @moduledoc """
  The Engine context.
  """

  import Ecto.Query, warn: false
  alias Mud.Repo

  alias Mud.Engine.Area
  alias Mud.Engine.Character

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
  Gets a single area from the location value of a Character.

  Raises `Ecto.NoResultsError` if the Area does not exist.

  ## Examples

      iex> get_area!(123)
      %Area{}

      iex> get_area!(456)
      ** (Ecto.NoResultsError)

  """
  def get_area_from_character!(id) do
    Repo.one!(
      from(area in Area,
        join: character in Character,
        on: character.location_id == area.id,
        where: character.id == ^id,
        select: area
      )
    )
  end

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
    IO.inspect({"find_obvious_exit_in_character_location", character_id, direction})

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
  Returns the list of characters.

  ## Examples

      iex> list_characters()
      [%Character{}, ...]

  """
  def list_characters_in_areas(area_ids) do
    Repo.all(
      from(
        character in Character,
        where: character.location_id in ^List.wrap(area_ids)
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
  def get_character!(id), do: Repo.get!(Character, id)

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

    %Character{}
    |> Character.changeset(attrs)
    |> Repo.insert()
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
    spec = {Mud.Engine.Session, character_id: character_id}
    DynamicSupervisor.start_child(Mud.Engine.CharacterSessionSupervisor, spec)
    :ok
  end

  def subscribe_to_character_input_messages(character_id) do
    :ok = Phoenix.PubSub.subscribe(Mud.PubSub, "character:input:#{character_id}")
  end

  def subscribe_to_character_output_messages(character_id) do
    :ok = Phoenix.PubSub.subscribe(Mud.PubSub, "character:output:#{character_id}")
  end

  def send_message_for(%Mud.Engine.Message{} = message) do
    Phoenix.PubSub.broadcast(
      Mud.PubSub,
      "character:#{message.type}:#{message.character_id}",
      {message.type, message}
    )
  end
end
