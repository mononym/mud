defmodule Mud.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links) do
      add :type, :string
      add :text, :string
      add :from, references(:areas, on_delete: :nothing)
      add :to, references(:areas, on_delete: :nothing)

      timestamps()
    end

    create index(:links, [:from])
    create index(:links, [:to])
  end
end
