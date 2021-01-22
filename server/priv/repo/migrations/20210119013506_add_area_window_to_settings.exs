defmodule Mud.Repo.Migrations.AddAreaWindowToSettings do
  use Ecto.Migration

  def change do
    alter table(:character_settings) do
      add(:area_window, :map)
      add(:inventory_window, :map)
    end
  end
end
