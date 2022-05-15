defmodule Mud.Repo.Migrations.AddKeyToMap do
  use Ecto.Migration

  def up do
    alter table(:maps) do
      remove(:permanently_explored)
      add(:key, :string)
    end

    drop_if_exists(index(:maps, [:permanently_explored]))
    create(index(:maps, [:key]))
  end

  def down do
    alter table(:maps) do
      add(:permanently_explored, :string)
      remove(:key)
    end

    create(index(:maps, [:permanently_explored]))
    drop_if_exists(index(:maps, [:key]))
  end
end
