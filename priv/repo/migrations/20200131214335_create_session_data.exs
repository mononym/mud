defmodule Mud.Repo.Migrations.AddCharacterSessionData do
  use Ecto.Migration

  def change do
    create table(:character_session_data, primary_key: false) do
      add(:data, :binary)

      add(:character_id, references(:characters, on_delete: :delete_all, type: :binary_id),
        primary_key: true
      )
      
      timestamps()
    end

    create(unique_index(:character_session_data, [:character_id]))
  end
end
