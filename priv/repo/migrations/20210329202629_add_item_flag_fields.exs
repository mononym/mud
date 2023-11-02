defmodule Mud.Repo.Migrations.AddItemFlagFields do
  use Ecto.Migration

  def down do
    alter table(:item_flags) do
      remove(:is_closable)
    end

    drop_if_exists(index(:item_flags, [:is_closable]))
  end

  def up do
    alter table(:item_flags) do
      add(:is_closable, :boolean, default: false)
    end

    create(index(:item_flags, [:is_closable]))
  end
end
