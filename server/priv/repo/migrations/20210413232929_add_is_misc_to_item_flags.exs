defmodule Mud.Repo.Migrations.AddIsIsMiscToItemFlags do
  use Ecto.Migration

  def down do
    alter table(:item_flags) do
      remove(:is_misc)
    end
  end

  def up do
    alter table(:item_flags) do
      add(:is_misc, :boolean, default: false)
    end

    create(index(:item_flags, [:is_misc]))
  end
end
