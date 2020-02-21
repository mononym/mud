defmodule Mud.Repo.Migrations.CreateSceneryComponents do
  use Ecto.Migration

  def change do
    create table(:scenery_components, primary_key: false) do
      add(:hidden, :boolean, default: false, null: false)

      add(:object_id, references(:objects, on_delete: :delete_all, type: :binary_id),
        primary_key: true
      )
    end

    create(index(:scenery_components, [:hidden]))
  end
end
