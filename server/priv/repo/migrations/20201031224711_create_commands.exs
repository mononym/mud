defmodule Mud.Repo.Migrations.CreateCommands do
  use Ecto.Migration

  def change do
    create table(:commands, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string)
      add(:description, :string)
      add(:parts, {:array, :map})
      add(:instance_id, references(:instances, on_delete: :delete_all, type: :binary_id))
      add(:lua_script_id, references(:lua_scripts, on_delete: :nilify_all, type: :binary_id))

      timestamps()
    end

    create(index(:commands, [:instance_id]))
    create(index(:commands, [:lua_script_id]))
  end
end
