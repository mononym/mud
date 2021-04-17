defmodule Mud.Repo.Migrations.AddNewWindowsToSettings do
  use Ecto.Migration

  def down do
    alter table(:character_settings) do
      remove(:directions_window)
      remove(:environment_window)
      remove(:status_window)
    end
  end

  def up do
    alter table(:character_settings) do
      add(:directions_window, :map)
      add(:environment_window, :map)
      add(:status_window, :map)
    end
  end
end
