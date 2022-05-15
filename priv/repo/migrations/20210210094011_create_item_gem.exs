defmodule Mud.Repo.Migrations.CreateItemGem do
  use Ecto.Migration

  def change do
    create table(:item_gems, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:item_id, references(:items, on_delete: :delete_all, type: :binary_id))

      add(:cut_type, :string, default: 0)
      add(:cut_quality, :integer, default: 10)
      add(:clarity, :integer, default: 10)
      add(:saturation, :integer, default: 5)
      add(:tone, :integer, default: 5)
      add(:hue, :string)
      add(:carat, :float, default: 1.0)
      add(:pre_mod, :string)
      add(:post_mod, :string)
      add(:type, :string)
    end

    create(index(:item_gems, [:cut_type]))
    create(index(:item_gems, [:cut_quality]))
    create(index(:item_gems, [:clarity]))
    create(index(:item_gems, [:saturation]))
    create(index(:item_gems, [:tone]))
    create(index(:item_gems, [:hue]))
    create(index(:item_gems, [:carat]))
    create(index(:item_gems, [:pre_mod]))
    create(index(:item_gems, [:post_mod]))
    create(index(:item_gems, [:type]))
    create(unique_index(:item_gems, [:item_id]))
  end
end
