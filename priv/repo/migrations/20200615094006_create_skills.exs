defmodule Mud.Repo.Migrations.CreateSkills do
  use Ecto.Migration

  def change do
    create table(:character_skills, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string)
      add(:skillset, :string)
      add(:pool, :integer)
      add(:points, :integer)
      add(:last_pulse, :utc_datetime)

      add(:character_id, references(:characters, on_delete: :delete_all, type: :binary_id))
    end

    create(index(:character_skills, [:name]))
    create(index(:character_skills, [:skillset]))
    create(index(:character_skills, [:pool]))
    create(index(:character_skills, [:points]))
  end
end
