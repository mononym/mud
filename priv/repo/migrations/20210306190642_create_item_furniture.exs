defmodule Mud.Repo.Migrations.CreateItemFurniture do
  use Ecto.Migration

  def change do
    create table(:item_furniture, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:item_id, references(:items, on_delete: :delete_all, type: :binary_id))

      add(:external_surface_can_hold_characters, :boolean, default: false)
      add(:external_surface_size, :integer, default: 1)
      add(:has_external_surface, :boolean, default: false)

      add(:internal_surface_can_hold_characters, :boolean, default: false)
      add(:internal_surface_size, :integer, default: 1)
      add(:has_internal_surface, :boolean, default: false)
    end

    create(index(:item_furniture, [:external_surface_can_hold_characters]))
    create(index(:item_furniture, [:external_surface_size]))
    create(index(:item_furniture, [:has_external_surface]))
    create(index(:item_furniture, [:internal_surface_can_hold_characters]))
    create(index(:item_furniture, [:internal_surface_size]))
    create(index(:item_furniture, [:has_internal_surface]))
    create(unique_index(:item_furniture, [:item_id]))
  end
end
