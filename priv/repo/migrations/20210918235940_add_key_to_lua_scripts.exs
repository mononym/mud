defmodule Mud.Repo.Migrations.AddKeyToLuaScripts do
  use Ecto.Migration

  def up do
    alter table(:lua_scripts) do
      add(:key, :string)
    end

    create(unique_index(:lua_scripts, [:key]))

    create(index(:lua_scripts, [:type]))
  end

  def down do
    alter table(:lua_scripts) do
      remove(:key)
    end

    drop_if_exists(index(:lua_scripts, [:key]))
  end
end
