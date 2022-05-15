defmodule Mud.Repo.Migrations.AddTemplates do
  use Ecto.Migration

  def change do
    create table(:templates, primary_key: false) do
      add(:id, :binary_id, primary_key: true)

      add(:name, :citext)
      add(:description, :citext)
      add(:template, :map)
    end

    create(index(:templates, [:name]))
    create(index(:templates, [:description]))
  end
end
