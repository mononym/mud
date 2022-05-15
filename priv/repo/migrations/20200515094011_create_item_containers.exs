defmodule Mud.Repo.Migrations.CreateItemContainers do
  use Ecto.Migration

  def change do
    create table(:item_containers, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:item_id, references(:items, on_delete: :delete_all, type: :binary_id))

      add(:capacity, :integer, default: 1)
      add(:height, :integer, default: 1)
      add(:length, :integer, default: 1)
      add(:width, :integer, default: 1)
      add(:locked, :boolean, default: false)
      add(:open, :boolean, default: true)
    end

    create(index(:item_containers, [:capacity]))
    create(index(:item_containers, [:height]))
    create(index(:item_containers, [:length]))
    create(index(:item_containers, [:width]))
    create(index(:item_containers, [:locked]))
    create(index(:item_containers, [:open]))
    create(index(:item_containers, [:item_id]))
  end
end
