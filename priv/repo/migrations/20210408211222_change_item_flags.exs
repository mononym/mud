defmodule Mud.Repo.Migrations.ChangeItemFlags do
  use Ecto.Migration

  def up do
    drop_if_exists(index(:item_flags, [:clothing]))

    alter table(:item_flags) do
      remove(:clothing)
      add(:is_clothing, :boolean, default: false)
    end

    create(index(:item_flags, [:is_clothing]))
  end

  def down do
    drop_if_exists(index(:item_flags, [:is_clothing]))

    alter table(:item_flags) do
      remove(:is_clothing)
      add(:clothing, :boolean, default: false)
    end

    create(index(:item_flags, [:clothing]))
  end
end
