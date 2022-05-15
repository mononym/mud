defmodule Mud.Repo.Migrations.RemoveOldItemFlags do
  use Ecto.Migration

  def up do
    alter table(:item_flags) do
      remove(:container)
    end

    drop_if_exists(index(:item_flags, [:container]))
  end

  def down do
    alter table(:item_flags) do
      add(:container, :boolean, default: false)
    end

    create(index(:item_flags, [:container]))
  end
end
