defmodule Mud.Repo.Migrations.AddEchoToSettings do
  use Ecto.Migration

  def change do
    alter table(:character_settings) do
      add(:echo, :map)
    end
  end
end
