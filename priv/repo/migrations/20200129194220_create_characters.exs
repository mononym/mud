defmodule Mud.Repo.Migrations.CreateCharacters do
  use Ecto.Migration

  def change do
    create table(:characters, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :citext)
      add(:active, :boolean)

      add(:strength, :integer)
      add(:stamina, :integer)
      add(:constitution, :integer)
      add(:dexterity, :integer)
      add(:agility, :integer)
      add(:reflexes, :integer)
      add(:intelligence, :integer)
      add(:wisdom, :integer)
      add(:charisma, :integer)

      add(:race, :string)
      add(:eye_color, :string)
      add(:hair_color, :string)
      add(:skin_color, :string)
      add(:position, :string)
      add(:relative_position, :string)

      add(:player_id, references(:players, on_delete: :nothing, type: :binary_id))

      add(:area_id, references(:areas, on_delete: :nilify_all, type: :binary_id))

      timestamps()
    end

    create(index(:characters, [:active]))
    create(index(:characters, [:player_id]))
    create(index(:characters, [:strength]))
    create(index(:characters, [:stamina]))
    create(index(:characters, [:constitution]))
    create(index(:characters, [:dexterity]))
    create(index(:characters, [:agility]))
    create(index(:characters, [:reflexes]))
    create(index(:characters, [:intelligence]))
    create(index(:characters, [:wisdom]))
    create(index(:characters, [:charisma]))
    create(index(:characters, [:race]))
    create(index(:characters, [:eye_color]))
    create(index(:characters, [:hair_color]))
    create(index(:characters, [:skin_color]))
    create(index(:characters, [:area_id]))
    create(unique_index(:characters, [:name]))
    execute("CREATE INDEX name_tgm_idx ON characters USING GIN (name gin_trgm_ops)")
  end
end
