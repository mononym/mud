defmodule Mud.Repo.Migrations.AddConfigValuesToMap do
  use Ecto.Migration

  def change do
    alter table(:maps) do
      add(:map_size, :integer)
      add(:grid_size, :integer)
      add(:max_zoom, :integer)
      add(:min_zoom, :integer)
      add(:default_zoom, :integer)
    end

    create(index(:maps, [:map_size]))
    create(index(:maps, [:grid_size]))
    create(index(:maps, [:max_zoom]))
    create(index(:maps, [:min_zoom]))
    create(index(:maps, [:default_zoom]))
  end
end
