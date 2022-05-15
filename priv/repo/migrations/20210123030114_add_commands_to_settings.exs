defmodule Mud.Repo.Migrations.AddCommandsToSettings do
  use Ecto.Migration

  def change do
    alter table(:character_settings) do
      add(:commands, :map)
    end
  end
end
