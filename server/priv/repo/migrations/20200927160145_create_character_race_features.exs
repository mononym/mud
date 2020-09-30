defmodule Mud.Repo.Migrations.CreateCharacterRaceFeature do
  use Ecto.Migration

  def change do
    create table(:character_race_features, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string)
      add(:type, :string)
      add(:instance_id, references(:instances, on_delete: :nothing, type: :binary_id))

      timestamps()
    end

    create(index(:character_race_features, [:instance_id]))
    create(unique_index(:character_race_features, [:name]))
    create(index(:character_race_features, [:type]))
  end
end
