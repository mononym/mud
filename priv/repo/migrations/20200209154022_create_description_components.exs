defmodule Mud.Repo.Migrations.CreateDescriptionComponents do
  use Ecto.Migration

  def change do
    create table(:description_components, primary_key: false) do
      add(:glance_description, :string, null: false)
      add(:glance_description_tsv, :tsvector)
      add(:look_description, :string)
      add(:look_description_tsv, :tsvector)
      add(:examine_description, :string)
      add(:examine_description_tsv, :tsvector)

      add(:object_id, references(:objects, on_delete: :delete_all, type: :binary_id),
        primary_key: true
      )

      timestamps()
    end
  end
end
