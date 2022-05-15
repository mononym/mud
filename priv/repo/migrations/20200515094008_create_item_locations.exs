defmodule Mud.Repo.Migrations.CreateItemLocations do
  use Ecto.Migration

  def change do
    create table(:item_locations, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:item_id, references(:items, on_delete: :delete_all, type: :binary_id))

      add(:hand, :citext, default: "right")
      add(:held_in_hand, :boolean, default: false)
      add(:area_id, references(:areas, on_delete: :delete_all, type: :binary_id))
      add(:character_id, references(:characters, on_delete: :delete_all, type: :binary_id))
      add(:relative_item_id, references(:items, on_delete: :delete_all, type: :binary_id))
      add(:moved_at, :utc_datetime_usec)
      add(:on_ground, :boolean, default: false)
      add(:relation, :string, default: "in")
      add(:relative_to_item, :boolean, default: false)
      add(:worn_on_character, :boolean, default: false)
      add(:stow_home_id, references(:items, on_delete: :nilify_all, type: :binary_id))
    end

    create(index(:item_locations, [:hand]))
    create(index(:item_locations, [:held_in_hand]))
    create(index(:item_locations, [:area_id]))
    create(index(:item_locations, [:character_id]))
    create(index(:item_locations, [:relative_item_id]))
    create(index(:item_locations, [:moved_at]))
    create(index(:item_locations, [:on_ground]))
    create(index(:item_locations, [:relation]))
    create(index(:item_locations, [:relative_to_item]))
    create(index(:item_locations, [:worn_on_character]))
    create(index(:item_locations, [:item_id]))
    create(index(:item_locations, [:stow_home_id]))
  end
end
