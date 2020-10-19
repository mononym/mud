defmodule Mud.Repo.Migrations.CreateMaps do
  use Ecto.Migration

  def change do
    create table(:maps, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :citext
      add :description, :text

      timestamps()
    end

    create(unique_index(:maps, [:name]))
  end
end
