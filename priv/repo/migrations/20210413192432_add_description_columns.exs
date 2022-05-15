defmodule Mud.Repo.Migrations.AddDescriptionColumns do
  use Ecto.Migration

  def up do
    alter table(:item_descriptions) do
      remove(:long)
    end
  end

  def down do
    alter table(:item_descriptions) do
      add(:long, :citext, default: "")
    end
  end
end
