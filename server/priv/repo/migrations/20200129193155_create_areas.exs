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

      timestamps()
    end

    create(index(:areas, [:name]))
  end
end
