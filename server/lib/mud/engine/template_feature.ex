defmodule Mud.Engine.TemplateFeature do
  use Ecto.Schema
  alias Mud.Engine.CharacterTemplate
  alias Mud.Engine.CharacterRaceFeature
  alias Mud.Repo

  import Ecto.Query

  @primary_key false
  schema "race_features" do
    belongs_to(:character_template, CharacterTemplate, type: :binary_id)
    belongs_to(:character_race_feature, CharacterRaceFeature, type: :binary_id)
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, [:character_template_id, :character_race_feature_id])
    |> Ecto.Changeset.validate_required([:character_template_id, :character_race_feature_id])
  end

  @doc """
  Link a Template and a Feature

  ## Examples

      iex> link(%{character_template_id: good_value, character_race_feature_id: good_value})
      {:ok, %RaceFeature{}}

      iex> link(%{character_template_id: bad_value, character_race_feature_id: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def link(template_id, feature_id) do
    %__MODULE__{}
    |> __MODULE__.changeset(%{
      character_template_id: template_id,
      character_race_feature_id: feature_id
    })
    |> Repo.insert()
  end

  def unlink(template_id, feature_id) do
    from(link in __MODULE__,
      where:
        link.character_template_id == ^template_id and
          link.character_race_feature_id == ^feature_id
    )
    |> Repo.delete_all()

    :ok
  end
end
