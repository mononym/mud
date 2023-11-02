defmodule Mud.Repo.Migrations.CreateItemWearable do
  use Ecto.Migration

  def change do
    create table(:item_wearables, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:item_id, references(:items, on_delete: :delete_all, type: :binary_id))

      add(:slot, :string)
    end

    create(index(:item_wearables, [:slot]))
    create(unique_index(:item_wearables, [:item_id]))
  end
end
