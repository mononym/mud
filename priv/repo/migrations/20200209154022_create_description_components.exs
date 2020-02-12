defmodule Mud.Repo.Migrations.CreateDescriptionComponents do
  use Ecto.Migration

  def change do
    create table(:description_components, primary_key: false) do
      add(:glance_description, :citext, null: false)
      add(:look_description, :citext)
      add(:examine_description, :citext)

      add(:object_id, references(:objects, on_delete: :delete_all, type: :binary_id),
        primary_key: true
      )

      timestamps()
    end
  end
end
