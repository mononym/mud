defmodule Mud.Repo.Migrations.CreateLuaScriptsDependencies do
  use Ecto.Migration

  def change do
    alter table(:lua_scripts, primary_key: false) do
      add(:script_id, references(:lua_scripts, on_delete: :delete_all, type: :binary_id))
      add(:dependency_id, references(:lua_scripts, on_delete: :delete_all, type: :binary_id))
    end

    create(unique_index(:lua_scripts, [:script_id, :dependency_id]))
  end
end
