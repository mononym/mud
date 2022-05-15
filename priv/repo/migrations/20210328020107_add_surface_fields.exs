defmodule Mud.Repo.Migrations.AddSurfaceFields do
  use Ecto.Migration

  def down do
    alter table(:item_surface) do
      remove(:length)
      remove(:width)
      remove(:items_must_fit)
    end

    drop_if_exists(index(:item_surface, [:length]))
    drop_if_exists(index(:item_surface, [:width]))
    drop_if_exists(index(:item_surface, [:items_must_fit]))
  end

  def up do
    alter table(:item_surface) do
      add(:length, :integer, default: 0)
      add(:width, :integer, default: 0)
      add(:items_must_fit, :boolean, default: false)
    end

    create(index(:item_surface, [:length]))
    create(index(:item_surface, [:width]))
    create(index(:item_surface, [:items_must_fit]))
  end
end
