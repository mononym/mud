defmodule Mud.Repo.Migrations.CreateShopProduct do
  use Ecto.Migration

  def change do
    create table(:shop_products, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:shop_id, references(:shops, on_delete: :delete_all, type: :binary_id))

      add(:description, :citext)

      add(:copper, :bigint, default: 0)
      add(:bronze, :bigint, default: 0)
      add(:silver, :bigint, default: 0)
      add(:gold, :bigint, default: 0)
    end

    create(index(:shop_products, [:description]))
    create(index(:shop_products, [:shop_id]))
    create(index(:shop_products, [:copper]))
    create(index(:shop_products, [:bronze]))
    create(index(:shop_products, [:silver]))
    create(index(:shop_products, [:gold]))
  end
end
