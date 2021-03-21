defmodule Mud.Repo.Migrations.UpdateFieldsForFurniture do
  use Ecto.Migration

  def up do
    alter table(:item_furniture) do
      remove(:internal_surface_size)
      remove(:external_surface_size)
      remove(:external_surface_can_hold_characters)
      remove(:internal_surface_can_hold_characters)
    end
  end

  def down do
    alter table(:item_furniture) do
      add(:internal_surface_size, :integer, default: 1)
      add(:external_surface_size, :integer, default: 1)
      add(:external_surface_can_hold_characters, :boolean, default: false)
      add(:internal_surface_can_hold_characters, :boolean, default: false)
    end

    create(index(:item_furniture, [:internal_surface_size]))
    create(index(:item_furniture, [:external_surface_size]))

    create(index(:item_furniture, [:external_surface_can_hold_characters]))
    create(index(:item_furniture, [:internal_surface_can_hold_characters]))
  end
end
