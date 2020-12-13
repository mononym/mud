defmodule Mud.Repo.Migrations.AddColorToLabel do
  use Ecto.Migration

  def change do
    alter table(:links) do
      add(:local_from_label_color, :string, default: "#000000")
      add(:local_to_label_color, :string, default: "#000000")
      add(:label_color, :string, default: "#000000")
    end
  end
end
