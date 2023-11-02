defmodule Mud.Repo.Migrations.AddAudioSettingsToCharacter do
  use Ecto.Migration

  def down do
    alter table(:character_settings) do
      remove(:audio)
    end
  end

  def up do
    alter table(:character_settings) do
      add(:audio, :map, default: %{})
    end
  end
end
