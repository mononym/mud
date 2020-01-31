defmodule Mud.Repo.Migrations.AddActiveToCharacter do
  use Ecto.Migration

  def change do
    alter table(:characters) do
      add(:active, :boolean, default: false)
    end
  end
end
