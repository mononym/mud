defmodule Mud.Repo.Migrations.CreateItemCoin do
  use Ecto.Migration

  def change do
    create table(:item_coins, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:item_id, references(:items, on_delete: :delete_all, type: :binary_id))

      add(:count, :bigint, default: 0)
      add(:copper, :boolean, default: false)
      add(:bronze, :boolean, default: false)
      add(:silver, :boolean, default: false)
      add(:gold, :boolean, default: false)
    end

    create(index(:item_coins, [:count]))
    create(index(:item_coins, [:copper]))
    create(index(:item_coins, [:bronze]))
    create(index(:item_coins, [:silver]))
    create(index(:item_coins, [:gold]))
    create(unique_index(:item_coins, [:item_id]))
  end
end
