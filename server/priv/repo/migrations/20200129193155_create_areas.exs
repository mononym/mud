defmodule Mud.Repo.Migrations.CreateAreas do
  use Ecto.Migration

  def change do
    create table(:areas, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :citext)
      add(:description, :text)
      add(:map_x, :integer)
      add(:map_y, :integer)
      add(:map_size, :integer)

      add(:region_id, references(:regions, on_delete: :nilify_all, type: :binary_id))
      add(:instance_id, references(:instances, on_delete: :delete_all, type: :binary_id))

      timestamps()
    end

    create(index(:areas, [:instance_id]))
    create(index(:areas, [:name]))
    create(index(:areas, [:map_x]))
    create(index(:areas, [:map_y]))
  end
end
