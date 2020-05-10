defmodule Mud.Repo.Migrations.CreateCharacterPhysicalFeaturesComponents do
  use Ecto.Migration

  def change do
    create table(:character_physical_features_components, primary_key: false) do
      add(:race, :citext)
      add(:eye_color, :citext)
      add(:hair_color, :citext)
      add(:skin_color, :citext)

      add(:character_id, references(:characters, on_delete: :delete_all, type: :binary_id),
        primary_key: true
      )
    end

    create(index(:character_physical_features_components, [:race]))
    create(index(:character_physical_features_components, [:eye_color]))
    create(index(:character_physical_features_components, [:hair_color]))
    create(index(:character_physical_features_components, [:skin_color]))
  end
end
