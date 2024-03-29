defmodule Mud.Repo.Migrations.CreateLuaScripts do
  use Ecto.Migration

  def change do
    create table(:lua_scripts, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string)
      add(:type, :string)
      add(:key, :string)
      add(:code, :text)
      add(:description, :text)

      timestamps()
    end

    create(unique_index(:lua_scripts, [:name]))
    create(unique_index(:lua_scripts, [:key]))
    create(index(:lua_scripts, [:type]))
  end
end
