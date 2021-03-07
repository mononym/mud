defmodule Mud.Repo.Migrations.AddFieldsToCharacterStatus do
  use Ecto.Migration

  def change do
    alter table(:character_status) do
      add(:item_id, references(:items, on_delete: :nilify_all, type: :binary_id))
      add(:position_relation, :string, default: "on")
      add(:position_relative_to_item, :boolean, default: false)
    end

    create(index(:character_status, [:position_relation]))
    create(index(:character_status, [:item_id]))
    create(index(:character_status, [:position_relative_to_item]))
  end
end
