defmodule Mud.Repo.Migrations.CreateCharacterSettings do
  use Ecto.Migration

  def change do
    create table(:character_settings, primary_key: false) do
      add(:id, :binary_id, primary_key: true)

      add(:character_id, references(:characters, on_delete: :delete_all, type: :binary_id))
    end

    create(index(:character_settings, [:character_id]))
  end
end
