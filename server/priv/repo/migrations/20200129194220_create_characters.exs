defmodule Mud.Repo.Migrations.CreateCharacters do
  use Ecto.Migration

  def change do
    create table(:characters, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :citext)
      add(:slug, :citext)
      add(:active, :boolean)
      add(:handedness, :string)
      add(:gender_pronoun, :string)
      add(:moved_location_at, :utc_datetime_usec)

      add(:strength, :integer)
      add(:stamina, :integer)
      add(:constitution, :integer)
      add(:dexterity, :integer)
      add(:agility, :integer)
      add(:reflexes, :integer)
      add(:intelligence, :integer)
      add(:wisdom, :integer)
      add(:charisma, :integer)

      add(:age, :integer)
      add(:race, :string)
      add(:eye_color, :string)
      add(:eye_accent_color, :string)
      add(:eye_color_type, :string)
      add(:hair_color, :string)
      add(:hair_style, :string)
      add(:hair_length, :string)
      add(:skin_tone, :string)
      add(:position, :string)
      add(:height, :string)

      add(:player_id, references(:players, on_delete: :nothing, type: :binary_id))

      add(:area_id, references(:areas, on_delete: :nilify_all, type: :binary_id))

      add(:auto_open_containers, :boolean)
      add(:auto_close_containers, :boolean)
      add(:auto_lock_containers, :boolean)
      add(:auto_unlock_containers, :boolean)

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
    create(index(:characters, [:age]))
    create(index(:characters, [:race]))
    create(index(:characters, [:eye_color]))
    create(index(:characters, [:eye_accent_color]))
    create(index(:characters, [:eye_color_type]))
    create(index(:characters, [:hair_color]))
    create(index(:characters, [:hair_style]))
    create(index(:characters, [:height]))
    create(index(:characters, [:skin_tone]))
    create(index(:characters, [:area_id]))
    create(index(:characters, [:position]))
    create(index(:characters, [:handedness]))
    create(unique_index(:characters, [:name]))
    create(unique_index(:characters, [:slug]))
    execute("CREATE INDEX name_tgm_idx ON characters USING GIN (name gin_trgm_ops)")
  end
end
