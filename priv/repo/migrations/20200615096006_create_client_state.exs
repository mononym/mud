defmodule Mud.Repo.Migrations.CreateClientState do
  use Ecto.Migration

  def change do
    create table(:character_client_states, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:state, :binary)

      add(:character_id, references(:characters, on_delete: :delete_all, type: :binary_id))
    end

    create(unique_index(:character_client_states, [:character_id]))
  end
end
