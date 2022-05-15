defmodule Mud.Repo.Migrations.AddFontSizeToLabel do
  use Ecto.Migration

  def change do
    alter table(:links) do
      add(:local_from_label_font_size, :integer, default: 8)
      add(:local_to_label_font_size, :integer, default: 8)
      add(:label_font_size, :integer, default: 8)
    end
  end
end
