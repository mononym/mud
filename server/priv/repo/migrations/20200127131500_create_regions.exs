defmodule Mud.Repo.Migrations.CreateRegions do
  use Ecto.Migration

  def change do
    create table(:regions, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :citext)

      timestamps()
    end

    create(index(:regions, [:name]))
  end
end
