defmodule Mud.Repo.Migrations.CreateObjects do
  use Ecto.Migration

  def change do
    create table(:objects, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:key, :citext)

      timestamps()
    end

    create(index(:objects, [:key]))
  end
end
