defmodule Mud.Repo.Migrations.CreateCharacterStatus do
  use Ecto.Migration

  def change do
    create table(:character_status, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:character_id, references(:characters, on_delete: :delete_all, type: :binary_id))

      add(:position, :string)
    end

    create(index(:character_status, [:position]))
    create(unique_index(:character_status, [:character_id]))
  end
end
