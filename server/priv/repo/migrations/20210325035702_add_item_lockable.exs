defmodule Mud.Repo.Migrations.AddItemLockable do
  use Ecto.Migration

  def up do
    create table(:item_lockable, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:item_id, references(:items, on_delete: :delete_all, type: :binary_id))
      add(:locked, :boolean, default: false)
    end

    create(index(:item_lockable, [:locked]))
    create(unique_index(:item_lockable, [:item_id]))
  end

  def down do
    drop(table(:item_lockable))
  end
end
