defmodule Mud.Repo.Migrations.CreateInstances do
  use Ecto.Migration

  def change do
    create table(:instances, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :citext)
      add(:slug, :citext)
      add(:description, :text)

      timestamps()
    end

    create(index(:instances, [:slug]))
  end
end
