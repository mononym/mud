defmodule Mud.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:type, :citext)
      add(:short_description, :citext)
      add(:long_description, :citext)
      add(:departure_text, :citext)
      add(:arrival_text, :citext)
      add(:icon, :citext)
      add(:local_from_x, :integer)
      add(:local_from_y, :integer)
      add(:local_from_size, :integer)
      add(:local_from_corners, :integer)
      add(:local_from_color, :string)
      add(:local_to_x, :integer)
      add(:local_to_y, :integer)
      add(:local_to_size, :integer)
      add(:local_to_corners, :integer)
      add(:local_to_color, :string)
      add(:from_id, references(:areas, on_delete: :delete_all, type: :binary_id))
      add(:to_id, references(:areas, on_delete: :delete_all, type: :binary_id))

      timestamps()
    end

    create(index(:links, [:departure_text]))
    create(index(:links, [:arrival_text]))
    create(index(:links, [:type]))
    create(index(:links, [:icon]))
    create(index(:links, [:short_description]))
    create(index(:links, [:long_description]))
    create(index(:links, [:from_id]))
    create(index(:links, [:to_id]))
    create(unique_index(:links, [:type, :from_id, :to_id]))
  end
end
