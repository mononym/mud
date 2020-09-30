defmodule Mud.Engine.CharacterRaceFeatureOption do
  @moduledoc """
  The Engine.CharacterRaceFeatureOption context.
  """

  import Ecto.Changeset
  import Ecto.Query, warn: false
  alias Mud.Repo
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "character_race_feature_options" do
    field(:conditions, :map)
    field(:option, :map)
    field(:character_race_feature_id, :binary_id)

    timestamps()
  end

  @doc false
  def changeset(character_race_feature_options, attrs) do
    character_race_feature_options
    |> cast(attrs, [:option, :conditions, :character_race_feature_id])
    |> validate_required([:option, :character_race_feature_id])
  end

  @doc """
  Returns the list of character_race_feature_options.

  ## Examples

      iex> list()
      [%CharacterRaceFeatureOption{}, ...]

  """
  def list do
    Repo.all(__MODULE__)
  end

  @doc """
  Gets a single character_race_feature_options.

  Raises `Ecto.NoResultsError` if the Character race feature options does not exist.

  ## Examples

      iex> get!(123)
      %CharacterRaceFeatureOption{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  def get!(id), do: Repo.get!(__MODULE__, id)

  @doc """
  Creates a character_race_feature_options.

  ## Examples

      iex> create(%{field: value})
      {:ok, %CharacterRaceFeatureOption{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> __MODULE__.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a character_race_feature_options.

  ## Examples

      iex> update(character_race_feature_options, %{field: new_value})
      {:ok, %CharacterRaceFeatureOption{}}

      iex> update(character_race_feature_options, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%__MODULE__{} = character_race_feature_options, attrs) do
    character_race_feature_options
    |> __MODULE__.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a character_race_feature_options.

  ## Examples

      iex> delete(character_race_feature_options)
      {:ok, %CharacterRaceFeatureOption{}}

      iex> delete(character_race_feature_options)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%__MODULE__{} = character_race_feature_options) do
    Repo.delete(character_race_feature_options)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking character_race_feature_options changes.

  ## Examples

      iex> change(character_race_feature_options)
      %Ecto.Changeset{data: %CharacterRaceFeatureOption{}}

  """
  def change(%__MODULE__{} = character_race_feature_options, attrs \\ %{}) do
    __MODULE__.changeset(character_race_feature_options, attrs)
  end
end
