defmodule Mud.Repo.Migrations.UpdateDataTypesForPhysics do
  use Ecto.Migration

  def up do
    drop_if_exists(index(:item_physics, [:length]))
    drop_if_exists(index(:item_physics, [:width]))
    drop_if_exists(index(:item_physics, [:height]))
    drop_if_exists(index(:item_physics, [:weight]))

    alter table(:item_physics) do
      modify(:length, :integer, default: 0)
      modify(:width, :integer, default: 0)
      modify(:height, :integer, default: 0)
      modify(:weight, :integer, default: 0)
    end

    create(index(:item_physics, [:length]))
    create(index(:item_physics, [:width]))
    create(index(:item_physics, [:height]))
    create(index(:item_physics, [:weight]))
  end

  def down do
    drop_if_exists(index(:item_physics, [:length]))
    drop_if_exists(index(:item_physics, [:width]))
    drop_if_exists(index(:item_physics, [:height]))
    drop_if_exists(index(:item_physics, [:weight]))

    alter table(:item_physics) do
      modify(:length, :float, default: 0.0)
      modify(:width, :float, default: 0.0)
      modify(:height, :float, default: 0.0)
      modify(:weight, :float, default: 0.0)
    end

    create(index(:item_physics, [:length]))
    create(index(:item_physics, [:width]))
    create(index(:item_physics, [:height]))
    create(index(:item_physics, [:weight]))
  end
end
