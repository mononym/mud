defmodule Mud.Engine.CharacterRaceFeature do
  @moduledoc """
  The Engine.CharacterRaceFeature context.
  """

  import Ecto.Query, warn: false
  alias Mud.Repo
  alias Mud.Engine.CharacterRaceFeatureOption
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "character_race_features" do
    field(:name, :string)
    field(:type, :string)
    field(:instance_id, :binary_id)

    has_many(:options, CharacterRaceFeatureOption)

    timestamps()
  end

  @doc false
  def changeset(character_race_feature, attrs) do
    character_race_feature
    |> cast(attrs, [:name, :type, :instance_id])
    |> validate_required([:name, :type, :instance_id])
  end

  @doc """
  Returns the list of character_race_feature.

  ## Examples

      iex> list()
      [%CharacterRaceFeature{}, ...]

  """
  def list do
    Repo.all(
      from(feature in __MODULE__,
        left_join: option in CharacterRaceFeatureOption,
        on: option.character_race_feature_id == feature.id,
        preload: [options: option]
      )
    )
    |> IO.inspect(label: "list")
  end

  @doc """
  Gets a single character_race_feature.

  Raises `Ecto.NoResultsError` if the Character race features does not exist.

  ## Examples

      iex> get!(123)
      %CharacterRaceFeature{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  def get!(id), do: Repo.get!(__MODULE__, id)

  @doc """
  Creates a character_race_feature.

  ## Examples

      iex> create(%{field: value})
      {:ok, %CharacterRaceFeature{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    feature =
      %__MODULE__{}
      |> __MODULE__.changeset(attrs)
      |> Repo.insert()

    case feature do
      {:ok, feature} ->
        {:ok, Repo.preload(feature, :options)}

      error ->
        error
    end
  end

  @doc """
  Updates a character_race_feature.

  ## Examples

      iex> update(character_race_feature, %{field: new_value})
      {:ok, %CharacterRaceFeature{}}

      iex> update(character_race_feature, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%__MODULE__{} = character_race_feature, attrs) do
    feature =
      character_race_feature
      |> __MODULE__.changeset(attrs)
      |> Repo.update()

    case feature do
      {:ok, feature} ->
        {:ok, Repo.preload(feature, :options)}

      error ->
        error
    end
  end

  @doc """
  Deletes a character_race_feature.

  ## Examples

      iex> delete(character_race_feature)
      {:ok, %CharacterRaceFeature{}}

      iex> delete(character_race_feature)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%__MODULE__{} = character_race_feature) do
    Repo.delete(character_race_feature)
  end
end
