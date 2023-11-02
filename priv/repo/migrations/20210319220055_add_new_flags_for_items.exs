defmodule Mud.Repo.Migrations.AddNewFlagsForItems do
  use Ecto.Migration

  def up do
    alter table(:item_flags) do
      add(:has_pocket, :boolean, default: false)
      add(:has_surface, :boolean, default: false)
    end

    create(index(:item_flags, [:has_pocket]))
    create(index(:item_flags, [:has_surface]))
  end

  def down do
    alter table(:item_flags) do
      remove(:has_pocket)
      remove(:has_surface)
    end
  end
end
