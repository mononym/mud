defmodule Mud.Repo.Migrations.CreateMapLabelTable do
  use Ecto.Migration

  def change do
    create table(:map_labels, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:map_id, references(:maps, on_delete: :delete_all, type: :binary_id))

      add(:text, :string, default: "", null: false)
      add(:x, :integer, default: 0, null: false)
      add(:y, :integer, default: 0, null: false)
      add(:vertical_offset, :integer, default: 0, null: false)
      add(:horizontal_offset, :integer, default: 0, null: false)
      add(:rotation, :integer, default: 0, null: false)
      add(:color, :string, default: "#FFFFFF", null: false)
      add(:size, :integer, default: 20, null: false)
      add(:weight, :integer, default: 50, null: false)

      timestamps()
    end

    create(index(:map_labels, [:map_id]))
  end
end
