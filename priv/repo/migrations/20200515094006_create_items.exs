defmodule Mud.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items, primary_key: false) do
      timestamps()
      add(:id, :binary_id, primary_key: true)
    end
  end
end
