defmodule Mud.Repo.Migrations.CreateCharacterSlots do
  use Ecto.Migration

  def change do
    create table(:character_slots, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:character_id, references(:characters, on_delete: :delete_all, type: :binary_id))

      add(:on_back, :integer, default: 1)
      add(:around_waist, :integer, default: 3)
      add(:on_belt, :integer, default: 6)
      add(:on_finger, :integer, default: 10)
      add(:over_shoulders, :integer, default: 1)
      add(:over_shoulder, :integer, default: 4)
      add(:on_head, :integer, default: 1)
      add(:in_hair, :integer, default: 1)
      add(:on_hair, :integer, default: 1)
      add(:around_neck, :integer, default: 3)
      add(:on_torso, :integer, default: 1)
      add(:on_legs, :integer, default: 1)
      add(:on_feet, :integer, default: 1)
      add(:on_hands, :integer, default: 1)
      add(:on_thigh, :integer, default: 2)
      add(:on_ankle, :integer, default: 4)
    end

    create(unique_index(:character_slots, [:character_id]))
  end
end
