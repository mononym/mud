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
    field(:instance_id, :binary_id)

    timestamps()
  end

  @doc """
  Returns the list of character_races.

  ## Examples

      iex> list()
      [%CharacterRace{}, ...]

  """
  def list do
    Repo.all(__MODULE__)
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
  def get!(id), do: Repo.get!(__MODULE__, id)

  @doc """
  Creates a character_race.

  ## Examples

      iex> create(%{field: value})
      {:ok, %CharacterRace{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> __MODULE__.changeset(attrs)
    |> Repo.insert()
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
    |> validate_required([:singular, :plural, :adjective, :portrait, :description])
  end
end
