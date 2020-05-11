defmodule Mud.Repo.Migrations.CreateObjectFurnitureComponents do
  use Ecto.Migration

  def change do
    create table(:object_furniture_components, primary_key: false) do
      add(:is_furniture, :boolean)

      add(:object_id, references(:objects, on_delete: :delete_all, type: :binary_id),
        primary_key: true
      )
    end

    create(index(:object_furniture_components, [:is_furniture]))
    create(unique_index(:object_furniture_components, [:object_id]))
  end
end
