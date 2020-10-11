defmodule Mud.Engine.CharacterRaceFeature do
  @moduledoc """
  The Engine.CharacterRaceFeature context.
  """

  import Ecto.Query, warn: false
  alias Mud.Repo
  use Ecto.Schema
  import Ecto.Changeset
  require Protocol

  @derive Jason.Encoder
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "character_race_features" do
    field(:name, :string)
    field(:field, :string)
    field(:key, :string)
    field(:type, :string)
    field(:instance_id, :binary_id)

    embeds_many :options, Option do
      @derive Jason.Encoder
      # These options are used for the range type
      field(:min, :integer, default: 0)
      field(:max, :integer, default: 0)
      # This option is used for the select type.
      field(:value, :string, default: "")
      # This option is used for the toggle type.
      field(:toggle, :boolean, default: false)

      embeds_many :conditions, Condition do
        @derive Jason.Encoder
        field(:key, :string, default: "")

        # If a condition is for a singular match, such as equals or notequals, the list will contain a single item.
        field(:values, {:array, :string}, default: [])
        field(:comparison, :string, default: "")
      end
    end

    timestamps()
  end

  @doc false
  def changeset(character_race_feature, attrs) do
    character_race_feature
    |> cast(attrs, [:name, :field, :key, :type, :instance_id])
    |> validate_required([:name, :field, :key, :type, :instance_id])
    |> cast_embed(:options, with: &option_changeset/2)
  end

  defp option_changeset(schema, params) do
    schema
    |> cast(params, [:min, :max, :value, :toggle])
    |> cast_embed(:conditions, with: &condition_changeset/2)
  end

  defp condition_changeset(schema, params) do
    schema
    |> cast(params, [:key, :values, :comparison])
  end

  @doc """
  Returns the list of character_race_feature.

  ## Examples

      iex> list()
      [%CharacterRaceFeature{}, ...]

  """
  def list do
    Repo.all(__MODULE__)
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
    # feature =
    %__MODULE__{}
    |> __MODULE__.changeset(attrs)
    |> Repo.insert()

    # case feature do
    #   {:ok, feature} ->
    #     {:ok, Repo.preload(feature, :options)}

    #   error ->
    #     error
    # end
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
    character_race_feature
    |> __MODULE__.changeset(attrs)
    |> Repo.update()
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
