defmodule Mud.Repo.Migrations.CreateAreas do
  use Ecto.Migration

  def change do
    create table(:areas, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :citext)
      add(:description, :text)
    end

    create(index(:areas, [:name]))
  end
end
