defmodule Mud.Repo.Migrations.CreateCharacterContainers do
  use Ecto.Migration

  def change do
    create table(:character_containers, primary_key: false) do
      add(:id, :binary_id, primary_key: true)

      add(:character_id, references(:characters, on_delete: :delete_all, type: :binary_id))
      add(:default_id, references(:items, on_delete: :nilify_all, type: :binary_id))
      add(:weapon_id, references(:items, on_delete: :nilify_all, type: :binary_id))
      add(:armor_id, references(:items, on_delete: :nilify_all, type: :binary_id))
      add(:gem_id, references(:items, on_delete: :nilify_all, type: :binary_id))
      add(:coin_id, references(:items, on_delete: :nilify_all, type: :binary_id))
      add(:ammunition_id, references(:items, on_delete: :nilify_all, type: :binary_id))
      add(:shield_id, references(:items, on_delete: :nilify_all, type: :binary_id))
      add(:clothing_id, references(:items, on_delete: :nilify_all, type: :binary_id))
      add(:scenery_id, references(:items, on_delete: :nilify_all, type: :binary_id))
    end

    create(unique_index(:character_containers, [:character_id]))
    create(index(:character_containers, [:default_id]))
    create(index(:character_containers, [:weapon_id]))
    create(index(:character_containers, [:armor_id]))
    create(index(:character_containers, [:gem_id]))
    create(index(:character_containers, [:coin_id]))
    create(index(:character_containers, [:ammunition_id]))
    create(index(:character_containers, [:shield_id]))
    create(index(:character_containers, [:clothing_id]))
    create(index(:character_containers, [:scenery_id]))
  end
end
