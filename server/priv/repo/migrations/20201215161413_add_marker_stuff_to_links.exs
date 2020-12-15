defmodule Mud.Repo.Migrations.AddMarkerStuffToLinks do
  use Ecto.Migration

  def change do
    alter table(:links) do
      add(:has_marker, :boolean, default: false)
      add(:marker_offset, :integer, default: 4)
    end
  end
end
