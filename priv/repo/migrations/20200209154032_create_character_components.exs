defmodule Mud.Repo.Migrations.CreateCharacterDescriptionComponents do
  use Ecto.Migration

  def change do
    create table(:character_description_components, primary_key: false) do
      add(:glance_description, :citext, null: false)
      add(:look_description, :citext)
      add(:examine_description, :citext)

      add(:object_id, references(:characters, on_delete: :delete_all, type: :binary_id),
        primary_key: true
      )
    end
  end
end
