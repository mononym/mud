defmodule Mud.Repo.Migrations.AddNewItemFlagFields do
  use Ecto.Migration

  def down do
    alter table(:item_flags) do
      remove(:has_physics)
    end

    drop_if_exists(index(:item_flags, [:has_physics]))
  end

  def up do
    alter table(:item_flags) do
      add(:has_physics, :boolean, default: false)
    end

    create(index(:item_flags, [:has_physics]))
  end
end
