defmodule Mud.Repo.Migrations.AddInstanceReferenceToLuaScripts do
  use Ecto.Migration

  def change do
    alter table(:lua_scripts) do
      add(:instance_id, references(:instances, on_delete: :delete_all, type: :binary_id))
    end

    create(index(:lua_scripts, [:instance_id]))
  end
end
