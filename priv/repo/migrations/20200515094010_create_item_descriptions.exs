defmodule Mud.Repo.Migrations.CreateItemDescriptions do
  use Ecto.Migration

  def change do
    create table(:item_descriptions, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:item_id, references(:items, on_delete: :delete_all, type: :binary_id))

      add(:short, :citext, default: "")
      add(:long, :citext, default: "")
      add(:key, :citext, default: "")
    end

    create(index(:item_descriptions, [:short]))
    create(index(:item_descriptions, [:long]))
    create(index(:item_descriptions, [:key]))
    create(index(:item_descriptions, [:item_id]))
  end
end
