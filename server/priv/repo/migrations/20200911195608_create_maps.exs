defmodule Mud.Repo.Migrations.CreateMaps do
  use Ecto.Migration

  def change do
    create table(:maps, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :citext)
      add(:description, :text)
      add(:grid_size, :integer)
      add(:view_size, :integer)
      add(:instance_id, references(:instances, on_delete: :delete_all, type: :binary_id))
      add(:labels, {:array, :map}, default: [])

      timestamps()
    end

    create(unique_index(:maps, [:name]))
  end
end
