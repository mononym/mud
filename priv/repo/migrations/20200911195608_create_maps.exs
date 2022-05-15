defmodule Mud.Repo.Migrations.CreateMaps do
  use Ecto.Migration

  def change do
    create table(:maps, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :citext)
      add(:description, :text)
      add(:grid_size, :integer)
      add(:view_size, :integer)
      add(:minimum_zoom_index, :integer)
      add(:maximum_zoom_index, :integer)
      add(:labels, {:array, :map}, default: [])
      add(:permanently_explored, :boolean, default: false)

      timestamps()
    end

    create(unique_index(:maps, [:name]))
    create(index(:maps, [:permanently_explored]))
  end
end
