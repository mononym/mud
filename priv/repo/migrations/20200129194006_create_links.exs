defmodule Mud.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:type, :citext)
      add(:description, :citext)
      add(:key, :citext)
      add(:departure_direction, :citext)
      add(:arrival_direction, :citext)
      add(:from_id, references(:areas, on_delete: :delete_all, type: :binary_id))
      add(:to_id, references(:areas, on_delete: :delete_all, type: :binary_id))
    end

    create(index(:links, [:departure_direction]))
    create(index(:links, [:arrival_direction]))
    create(index(:links, [:type]))
    create(index(:links, [:description]))
    create(index(:links, [:key]))
    create(index(:links, [:from_id]))
    create(index(:links, [:to_id]))
    create(unique_index(:links, [:type, :from_id, :to_id]))
  end
end
