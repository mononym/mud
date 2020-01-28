defmodule Mud.Repo.Migrations.CreateAreas do
  use Ecto.Migration

  def change do
    create table(:areas) do
      add :name, :string
      add :description, :string

      timestamps()
    end

  end
end
