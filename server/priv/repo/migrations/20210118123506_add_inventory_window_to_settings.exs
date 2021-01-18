defmodule Mud.Repo.Migrations.AddEchoToSettings do
  use Ecto.Migration

  def change do
    alter table(:character_settings) do
      add(:inventory_window, :map)
    end
  end
end
