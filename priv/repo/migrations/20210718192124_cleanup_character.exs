defmodule Mud.Repo.Migrations.CleanupCharacter do
  use Ecto.Migration

  def up do
    alter table(:characters) do
      remove(:handedness)
      remove(:position)
      remove(:gender_pronoun)
      add(:pronoun, :string)
    end

    drop_if_exists(index(:characters, [:handedness]))
    drop_if_exists(index(:characters, [:position]))
    drop_if_exists(index(:characters, [:gender_pronoun]))
  end

  def down do
    alter table(:characters) do
      add(:handedness, :string)
      add(:position, :string)
      add(:gender_pronoun, :string)
      remove(:pronoun)
    end
  end
end
