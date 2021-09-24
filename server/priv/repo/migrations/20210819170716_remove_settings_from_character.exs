defmodule Mud.Repo.Migrations.RemoveSettingsFromCharacter do
  use Ecto.Migration

  def down do
    alter table(:characters) do
      add(:auto_open_containers, :boolean)
      add(:auto_close_containers, :boolean)
      add(:auto_lock_containers, :boolean)
      add(:auto_unlock_containers, :boolean)
    end
  end

  def up do
    alter table(:characters) do
      remove(:auto_open_containers)
      remove(:auto_close_containers)
      remove(:auto_lock_containers)
      remove(:auto_unlock_containers)
    end
  end
end
