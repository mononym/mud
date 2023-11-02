defmodule Mud.Repo.Migrations.RemoveZoomIndexesFromMap do
  use Ecto.Migration

  def down do
    alter table(:maps) do
      add(:minimum_zoom_index, :integer)
      add(:maximum_zoom_index, :integer)
    end
  end

  def up do
    alter table(:maps) do
      remove(:minimum_zoom_index)
      remove(:maximum_zoom_index)
    end
  end
end
