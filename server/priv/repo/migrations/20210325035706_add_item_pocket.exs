defmodule Mud.Repo.Migrations.AddItemPocket do
  use Ecto.Migration

  def up do
    create table(:item_pockets, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:item_id, references(:items, on_delete: :delete_all, type: :binary_id))

      add(:capacity, :integer, default: 0)
      add(:height, :integer, default: 0)
      add(:length, :integer, default: 0)
      add(:width, :integer, default: 0)
    end

    create(index(:item_pockets, [:capacity]))
    create(index(:item_pockets, [:height]))
    create(index(:item_pockets, [:length]))
    create(index(:item_pockets, [:width]))
    create(unique_index(:item_pockets, [:item_id]))
  end

  def down do
    drop(table(:item_pockets))
  end
end
