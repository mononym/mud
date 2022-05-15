defmodule Mud.Repo.Migrations.AddRelationTableForRaceFeatures do
  use Ecto.Migration

  def change do
    create table(:race_features, primary_key: false) do
      add(
        :character_race_id,
        references(:character_races, on_delete: :delete_all, type: :binary_id)
      )

      add(
        :character_race_feature_id,
        references(:character_race_features, on_delete: :delete_all, type: :binary_id)
      )

      timestamps()
    end

    create(index(:race_features, [:character_race_id]))
    create(index(:race_features, [:character_race_feature_id]))

    create(
      unique_index(:race_features, [:character_race_id, :character_race_feature_id],
        name: :character_race_id_character_race_feature_id_unique_index
      )
    )
  end
end
