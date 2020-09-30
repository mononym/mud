defmodule Mud.Repo.Migrations.CreateCharacterRaceFeatureOption do
  use Ecto.Migration

  def change do
    create table(:character_race_feature_options, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:option, :map)
      add(:conditions, :map)

      add(
        :character_race_feature_id,
        references(:character_race_features, on_delete: :nothing, type: :binary_id)
      )

      timestamps()
    end

    create(index(:character_race_feature_options, [:character_race_feature_id]))
  end
end
