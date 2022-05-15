defmodule Mud.Repo.Migrations.AddMapWindowToSettings do
  use Ecto.Migration

  def change do
    alter table(:character_settings) do
      add(:map_window, :map)
    end
  end
end
