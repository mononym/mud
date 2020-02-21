defmodule Mud.Repo.Migrations.CreateLocationComponents do
  use Ecto.Migration

  def change do
    create table(:location_components, primary_key: false) do
      add(:on_ground, :boolean, default: false, null: false)
      add(:held, :boolean, default: false, null: false)
      add(:worn, :boolean, default: false, null: false)
      add(:hand, :string)
      add(:contained, :boolean, default: false, null: false)
      add(:reference, :string)

      add(:object_id, references(:objects, on_delete: :delete_all, type: :binary_id),
        primary_key: true
      )
    end

    create(index(:location_components, [:reference]))
    create(index(:location_components, [:contained]))
    create(index(:location_components, [:worn]))
    create(index(:location_components, [:held]))
    create(index(:location_components, [:on_ground]))
  end
end
