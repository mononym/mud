defmodule Mud.Repo.Migrations.CreateRegions do
  use Ecto.Migration

  def change do
    create table(:regions, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :citext)
      add(:instance_id, references(:instances, on_delete: :delete_all, type: :binary_id))

      timestamps()
    end

    create(index(:regions, [:name]))
    create(index(:regions, [:instance_id]))
  end
end
