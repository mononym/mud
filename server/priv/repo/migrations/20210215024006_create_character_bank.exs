defmodule Mud.Repo.Migrations.CreateCharacterBank do
  use Ecto.Migration

  def change do
    create table(:character_bank, primary_key: false) do
      add(:id, :binary_id, primary_key: true)

      add(:character_id, references(:characters, on_delete: :delete_all, type: :binary_id))

      add(:balance, :numeric, default: 0)
    end

    create(unique_index(:character_bank, [:character_id]))
    create(index(:character_bank, [:balance]))
  end
end
