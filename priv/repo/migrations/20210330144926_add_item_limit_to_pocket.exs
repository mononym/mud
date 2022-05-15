defmodule Mud.Repo.Migrations.AddItemLimitToPocket do
  use Ecto.Migration

  def down do
    alter table(:item_pockets) do
      remove(:item_limit)
    end

    drop_if_exists(index(:item_pockets, [:item_limit]))
  end

  def up do
    alter table(:item_pockets) do
      add(:item_limit, :integer, default: 0)
    end

    create(index(:item_pockets, [:item_limit]))
  end
end
