defmodule Mud.Repo.Migrations.CreateCharacterPhysicalStatusComponents do
  use Ecto.Migration

  def change do
    create table(:character_physical_status_components, primary_key: false) do
      add(:position, :citext)
      add(:relative_position, :citext)

      add(:character_id, references(:characters, on_delete: :delete_all, type: :binary_id),
        primary_key: true
      )

      add(:area_id, references(:areas, on_delete: :nilify_all, type: :binary_id),
        primary_key: false
      )

      add(:relative_object_id, references(:objects, on_delete: :nilify_all, type: :binary_id),
        primary_key: false
      )
    end

    create(index(:character_physical_status_components, [:position]))
    create(index(:character_physical_features_components, [:relative_position]))
    create(index(:character_physical_features_components, [:area_id]))
    create(index(:character_physical_features_components, [:relative_object_id]))
  end
end
