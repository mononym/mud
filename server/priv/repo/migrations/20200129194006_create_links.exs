defmodule Mud.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:type, :citext)
      add(:line_width, :integer, default: 2)
      add(:line_color, :string, default: "#FFFFFF")
      add(:line_dash, :integer, default: 0)
      add(:corners, :integer, default: 5)
      add(:short_description, :citext)
      add(:long_description, :citext)
      add(:departure_text, :citext)
      add(:arrival_text, :citext)
      add(:icon, :citext)
      add(:line_end_horizontal_offset, :integer, default: 0)
      add(:line_start_horizontal_offset, :integer, default: 0)
      add(:line_end_vertical_offset, :integer, default: 0)
      add(:line_start_vertical_offset, :integer, default: 0)
      add(:local_from_x, :integer, default: 0)
      add(:local_from_y, :integer, default: 0)
      add(:local_from_size, :integer, default: 21)
      add(:local_from_corners, :integer, default: 5)
      add(:local_from_color, :string, default: "#008080")
      add(:local_from_line_width, :integer, default: 2)
      add(:local_from_line_dash, :integer, default: 0)
      add(:local_from_line_color, :string, default: "#FFFFFF")
      add(:local_to_x, :integer, default: 0)
      add(:local_to_y, :integer, default: 0)
      add(:local_to_size, :integer, default: 21)
      add(:local_to_corners, :integer, default: 5)
      add(:local_to_color, :string, default: "#008080")
      add(:local_to_line_width, :integer, default: 2)
      add(:local_to_line_dash, :integer, default: 0)
      add(:local_to_line_color, :string, default: "#FFFFFF")
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
