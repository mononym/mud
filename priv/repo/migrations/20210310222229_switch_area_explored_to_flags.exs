defmodule Mud.Repo.Migrations.SwitchAreaExploredToFlags do
  use Ecto.Migration

  def change do
    drop(index(:areas, [:permanently_explored]))

    alter table(:areas) do
      remove(:permanently_explored)
    end

    alter table(:area_flags) do
      add(:permanently_explored, :boolean, default: false)
    end

    create(index(:area_flags, [:permanently_explored]))
  end
end
