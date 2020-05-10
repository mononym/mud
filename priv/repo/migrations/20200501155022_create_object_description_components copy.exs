defmodule Mud.Repo.Migrations.CreateObjectDescriptionComponents do
  use Ecto.Migration

  def change do
    create table(:object_description_components, primary_key: false) do
      add(:examine_description, :citext)
      add(:glance_description, :citext)
      add(:look_description, :citext)

      add(:object_id, references(:objects, on_delete: :delete_all, type: :binary_id),
        primary_key: true
      )
    end

    create(index(:object_description_components, [:examine_description]))
    create(index(:object_description_components, [:glance_description]))
    create(index(:object_description_components, [:look_description]))
  end
end
