defmodule Mud.Repo.Migrations.CreateItemPhysics do
  use Ecto.Migration

  def change do
    create table(:item_physics, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:item_id, references(:items, on_delete: :delete_all, type: :binary_id))

      add(:length, :integer, default: 1)
      add(:width, :integer, default: 1)
      add(:height, :integer, default: 1)
      add(:weight, :integer, default: 1)
    end

    create(index(:item_physics, [:length]))
    create(index(:item_physics, [:width]))
    create(index(:item_physics, [:height]))
    create(index(:item_physics, [:weight]))
    create(index(:item_physics, [:item_id]))
  end
end
