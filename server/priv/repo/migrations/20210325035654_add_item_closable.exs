defmodule Mud.Repo.Migrations.AddItemClosable do
  use Ecto.Migration

  def up do
    create table(:item_closable, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:item_id, references(:items, on_delete: :delete_all, type: :binary_id))
      add(:open, :boolean, default: true)
    end

    create(index(:item_closable, [:open]))
    create(unique_index(:item_closable, [:item_id]))
  end

  def down do
    drop(table(:item_closable))
  end
end
