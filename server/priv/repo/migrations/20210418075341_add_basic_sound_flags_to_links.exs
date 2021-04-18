defmodule Mud.Repo.Migrations.AddBasicSoundFlagsToLinks do
  use Ecto.Migration

  def down do
    alter table(:link_flags) do
      remove(:sound_travels_when_open)
      remove(:sound_travels_when_closed)
    end
  end

  def up do
    alter table(:link_flags) do
      add(:sound_travels_when_open, :boolean, default: true)
      add(:sound_travels_when_closed, :boolean, default: true)
    end

    create(index(:link_flags, [:sound_travels_when_open]))
    create(index(:link_flags, [:sound_travels_when_closed]))
  end
end
