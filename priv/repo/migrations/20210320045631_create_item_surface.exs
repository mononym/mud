defmodule Mud.Repo.Migrations.CreateItemSurface do
  use Ecto.Migration

  def up do
    create table(:item_surface, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:item_id, references(:items, on_delete: :delete_all, type: :binary_id))
      add(:can_hold_characters, :boolean, default: false)
      add(:item_count_limit, :integer, default: 1)
      add(:item_weight_limit, :integer, default: 1)
      add(:character_limit, :integer, default: 1)
      add(:show_item_contents, :boolean, default: false)
      add(:show_detailed_items, :boolean, default: false)
      add(:show_item_limit, :integer, default: 1)
    end

    create(index(:item_surface, [:can_hold_characters]))
    create(index(:item_surface, [:item_count_limit]))
    create(index(:item_surface, [:item_weight_limit]))
    create(index(:item_surface, [:character_limit]))
    create(index(:item_surface, [:show_item_contents]))
    create(index(:item_surface, [:show_detailed_items]))
    create(index(:item_surface, [:show_item_limit]))
    create(unique_index(:item_surface, [:item_id]))
  end

  def down do
    drop(table(:item_surface))
  end
end
