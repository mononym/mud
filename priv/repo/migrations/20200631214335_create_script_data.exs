defmodule Mud.Repo.Migrations.AddScriptData do
  use Ecto.Migration

  def change do
    create table(:script_data, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:callback_module, :string)
      add(:key, :string)
      add(:state, :binary)

      add(:area_id, references(:areas, on_delete: :delete_all, type: :binary_id))

      add(:character_id, references(:characters, on_delete: :delete_all, type: :binary_id))

      add(:item_id, references(:items, on_delete: :delete_all, type: :binary_id))

      add(:link_id, references(:links, on_delete: :delete_all, type: :binary_id))

      timestamps()
    end

    create(unique_index(:script_data, [:area_id, :key], where: "area_id IS NOT NULL"))

    create(unique_index(:script_data, [:character_id, :key], where: "character_id IS NOT NULL"))

    create(unique_index(:script_data, [:item_id, :key], where: "item_id IS NOT NULL"))
    create(unique_index(:script_data, [:link_id, :key], where: "link_id IS NOT NULL"))
    create(index(:script_data, [:key]))
    create(index(:script_data, [:callback_module]))
  end
end
