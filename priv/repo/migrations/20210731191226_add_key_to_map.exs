defmodule Mud.Repo.Migrations.AddKeyToMap do
  use Ecto.Migration

  def up do
    alter table(:maps) do
      add(:key, :string)
    end

    create(index(:maps, [:key]))
  end

  def down do
    alter table(:maps) do
      remove(:key)
    end

    drop_if_exists(index(:maps, [:key]))
  end
end
