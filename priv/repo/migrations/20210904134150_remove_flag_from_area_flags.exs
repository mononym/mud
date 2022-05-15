defmodule Mud.Repo.Migrations.RemoveFlagFromAreaFlags do
  use Ecto.Migration

  def down do
    alter table(:area_flags) do
      add(:permanently_explored, :boolean)
    end
  end

  def up do
    alter table(:area_flags) do
      remove(:permanently_explored)
    end
  end
end
