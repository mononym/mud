defmodule Mud.Repo.Migrations.AddLabelToLink do
  use Ecto.Migration

  def change do
    alter table(:links) do
      add(:local_from_label, :string, default: "")
      add(:local_from_label_flipped, :boolean, default: false)
      add(:local_from_label_horizontal_offset, :integer, default: 0)
      add(:local_from_label_vertical_offset, :integer, default: 0)

      add(:local_to_label, :string, default: "")
      add(:local_to_label_flipped, :boolean, default: false)
      add(:local_to_label_horizontal_offset, :integer, default: 0)
      add(:local_to_label_vertical_offset, :integer, default: 0)

      add(:label, :string, default: "")
      add(:label_flipped, :boolean, default: false)
      add(:label_horizontal_offset, :integer, default: 0)
      add(:label_vertical_offset, :integer, default: 0)
    end
  end
end
