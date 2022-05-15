defmodule Mud.Repo.Migrations.ModifyLinkDashVariables do
  use Ecto.Migration

  def up do
    alter table(:links) do
      remove(:line_dash)
      add(:line_dash, :string, default: "4,2")
      add(:line_dashed, :boolean, default: false)

      remove(:local_from_line_dash)
      add(:local_from_line_dash, :string, default: "4,2")
      add(:local_from_line_dashed, :boolean, default: false)

      remove(:local_to_line_dash)
      add(:local_to_line_dash, :string, default: "4,2")
      add(:local_to_line_dashed, :boolean, default: false)
    end
  end

  def down do
    alter table(:links) do
      remove(:line_dash)
      remove(:line_dashed)
      add(:line_dash, :integer, default: 0)

      remove(:local_from_line_dash)
      remove(:local_from_line_dashed)
      add(:local_from_line_dash, :integer, default: 0)

      remove(:local_to_line_dash)
      remove(:local_to_line_dashed, :boolean)
      add(:local_to_line_dash, :integer, default: 0)
    end
  end
end
