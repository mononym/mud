defmodule Mud.Repo.Migrations.CreateCharacterAttributes do
  use Ecto.Migration

  def change do
    create table(:attributes, primary_key: false) do
      add(:strength, :integer, default: 10, null: false)
      add(:stamina, :integer, default: 10, null: false)
      add(:constitution, :integer, default: 10, null: false)
      add(:dexterity, :integer, default: 10, null: false)
      add(:agility, :integer, default: 10, null: false)
      add(:reflexes, :integer, default: 10, null: false)
      add(:intelligence, :integer, default: 10, null: false)
      add(:wisdom, :integer, default: 10, null: false)
      add(:charisma, :integer, default: 10, null: false)

      add(:character_id, references(:characters, on_delete: :delete_all, type: :binary_id),
        primary_key: true
      )
    end

    create(index(:attributes, [:strength]))
    create(index(:attributes, [:stamina]))
    create(index(:attributes, [:constitution]))
    create(index(:attributes, [:dexterity]))
    create(index(:attributes, [:agility]))
    create(index(:attributes, [:reflexes]))
    create(index(:attributes, [:intelligence]))
    create(index(:attributes, [:wisdom]))
    create(index(:attributes, [:charisma]))
  end
end
