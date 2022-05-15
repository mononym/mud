defmodule Mud.Repo.Migrations.AddHotkeysToSettings do
  use Ecto.Migration

  def change do
    alter table(:character_settings) do
      add(:custom_hotkeys, {:array, :map})
      add(:preset_hotkeys, :map)
    end
  end
end
