defmodule Mud.Repo.Migrations.ChangeDescriptionColumns do
  use Ecto.Migration

  def up do
    alter table(:item_descriptions) do
      add(:details, :citext, default: "")
    end
  end

  def down do
    alter table(:item_descriptions) do
      remove(:details)
    end
  end
end
