defmodule Mud.Repo.Migrations.AddSubToPlayer do
  use Ecto.Migration

  def down do
    alter table(:players) do
      remove(:sub)
    end
  end

  def up do
    alter table(:players) do
      add(:sub, :string)
    end

    create(index(:players, [:sub]))
  end
end
