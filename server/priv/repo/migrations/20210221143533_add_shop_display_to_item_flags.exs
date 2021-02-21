defmodule Mud.Repo.Migrations.AddShopDisplayToItemFlags do
  use Ecto.Migration

  def change do
    alter table(:item_flags) do
      add(:shop_display, :boolean, default: false)
    end

    create(index(:item_flags, [:shop_display]))
  end
end
