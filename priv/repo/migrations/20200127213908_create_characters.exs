defmodule Mud.Repo.Migrations.CreateCharacters do
  use Ecto.Migration

  def change do
    create table(:characters) do
      add :name, :string

      timestamps()
    end

  end
end
