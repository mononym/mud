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
      add(:border_width, :integer)
      add(:border_color, :string)
      add(:color, :string)
      add(:permanently_explored, :boolean, default: false)

      timestamps()
    end

    create(index(:areas, [:name]))
    create(index(:areas, [:permanently_explored]))
  end
end
