defmodule Mud.Repo.Migrations.AddColorOptionsToSettings do
  use Ecto.Migration

  def change do
    alter table(:character_settings) do
      add(:colors, :map)
    end
  end
end
