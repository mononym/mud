defmodule Mud.Repo.Migrations.CreatePlayerRoles do
  use Ecto.Migration

  def change do
    create table(:player_roles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :player_id, references(:players, on_delete: :nothing, type: :binary_id)
      add :role_id, references(:roles, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:player_roles, [:player_id])
    create index(:player_roles, [:role_id])
  end
end
