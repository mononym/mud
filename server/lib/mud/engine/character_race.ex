defmodule Mud.Engine.CharacterRace do
  @moduledoc """
  The Engine.CharacterRace context.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  alias Mud.Repo

  @derive Jason.Encoder
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "character_races" do
    field(:adjective, :string)
    field(:description, :string)
    field(:plural, :string)
    field(:portrait, :string)
    field(:singular, :string)

    timestamps()
  end

  @doc """
  Returns the list of character_races.

  ## Examples

      iex> list()
      [%CharacterRace{}, ...]

  """
  def list do
    from(race in __MODULE__, preload: [:features])
    |> Repo.all()

    # preload_query =
    #   from(feature in CharacterRaceFeature,
    #   join: pt in "post_tags", on: pt.tag_id == t.id,
    #   join: c in assoc(t, :comment),
    #   preload: [comment: c])

    #   preload_query = from(t in Tag, join: c in assoc(t, :comment), preload: [comment: c])

    #       from(p in Post, preload: [tags: ^preload_query])
    #       |> PreloadTest.Repo.all()
  end

  @doc """
  Gets a single character_race.

  Raises `Ecto.NoResultsError` if the Character race does not exist.

  ## Examples

      iex> get!(123)
      %CharacterRace{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  def get!(id),
    do: Repo.one!(from(race in __MODULE__, where: race.id == ^id, preload: [:features]))

  @doc """
  Creates a character_race.

  ## Examples

      iex> create(%{field: value})
      {:ok, %CharacterRace{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    result =
      %__MODULE__{}
      |> __MODULE__.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, race} ->
        {:ok, Repo.preload(race, :features)}

      error ->
        error
    end
  end

  @doc """
  Updates a character_race.

  ## Examples

      iex> update(character_race, %{field: new_value})
      {:ok, %CharacterRace{}}

      iex> update(character_race, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%__MODULE__{} = character_race, attrs) do
    character_race
    |> __MODULE__.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a character_race.

  ## Examples

      iex> delete(character_race)
      {:ok, %CharacterRace{}}

      iex> delete(character_race)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%__MODULE__{} = character_race) do
    Repo.delete(character_race)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking character_race changes.

  ## Examples

      iex> change(character_race)
      %Ecto.Changeset{data: %CharacterRace{}}

  """
  def change(%__MODULE__{} = character_race, attrs \\ %{}) do
    __MODULE__.changeset(character_race, attrs)
  end

  @doc false
  def changeset(character_race, attrs) do
    character_race
    |> cast(attrs, [:singular, :plural, :adjective, :portrait, :description])
    |> validate_required([:singular, :plural, :adjective, :description])
  end

  # def changeset_update_projects(%User{} = user, projects) do
  #   user
  #   |> cast(%{}, @required_fields)
  #   # associate projects to the user
  #   |> put_assoc(:projects, projects)
  # end
end
