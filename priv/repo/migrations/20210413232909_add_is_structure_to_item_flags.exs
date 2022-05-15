defmodule Mud.Repo.Migrations.AddIsStructureToItemFlags do
  use Ecto.Migration

  def down do
    alter table(:item_flags) do
      remove(:is_structure)
      remove(:is_jewelry)
      add(:jewelry, :boolean, default: false)
    end

    create(index(:item_flags, [:jewelry]))
  end

  def up do
    alter table(:item_flags) do
      remove(:jewelry)
      add(:is_structure, :boolean, default: false)
      add(:is_jewelry, :boolean, default: false)
    end

    create(index(:item_flags, [:is_structure]))
    create(index(:item_flags, [:is_jewelry]))
  end
end
