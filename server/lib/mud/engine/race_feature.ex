defmodule Mud.Engine.RaceFeature do
  use Ecto.Schema
  alias Mud.Engine.CharacterRace
  alias Mud.Engine.CharacterRaceFeature
  alias Mud.Repo

  import Ecto.Query

  @primary_key false
  schema "race_features" do
    belongs_to(:character_race, CharacterRace, type: :binary_id)
    belongs_to(:character_race_feature, CharacterRaceFeature, type: :binary_id)
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, [:character_race_id, :character_race_feature_id])
    |> Ecto.Changeset.validate_required([:character_race_id, :character_race_feature_id])
  end

  @doc """
  Link a Race and a Feature

  ## Examples

      iex> link(%{character_race_id: good_value, character_race_feature_id: good_value})
      {:ok, %RaceFeature{}}

      iex> create(%{character_race_id: bad_value, character_race_feature_id: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def link(race_id, feature_id) do
    %__MODULE__{}
    |> __MODULE__.changeset(%{character_race_id: race_id, character_race_feature_id: feature_id})
    |> Repo.insert()
  end

  def unlink(race_id, feature_id) do
    from(link in __MODULE__,
      where: link.character_race_id == ^race_id and link.character_race_feature_id == ^feature_id
    )
    |> Repo.delete_all()

    :ok
  end
end
