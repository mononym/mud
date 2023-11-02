defmodule Mud.Repo.Migrations.AddMapCornersToArea do
  use Ecto.Migration

  def change do
    alter table(:areas) do
      add(:map_corners, :integer)
    end
  end
end
