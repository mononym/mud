defmodule Mud.Repo.Migrations.AddSecondaryColorToEyes do
  use Ecto.Migration

  def up do
    alter table(:physical_features) do
      add(:eye_color_secondary, :string)
      add(:eye_side_primary, :string)
      add(:heterochromia, :boolean)
    end
  end

  def down do
    alter table(:physical_features) do
      remove(:eye_color_secondary)
      remove(:eye_side_primary)
      remove(:heterochromia)
    end
  end
end
