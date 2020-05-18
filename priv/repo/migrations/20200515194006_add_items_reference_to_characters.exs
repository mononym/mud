defmodule Mud.Repo.Migrations.AddItemsReferenceToCharacter do
  use Ecto.Migration

  def change do
    alter table(:characters) do
      add(:relative_item_id, references(:items, on_delete: :nilify_all, type: :binary_id))
    end

    create(index(:characters, [:relative_item_id]))
  end
end
