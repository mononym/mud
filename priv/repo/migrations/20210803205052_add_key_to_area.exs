defmodule Mud.Repo.Migrations.AddKeyToArea do
  use Ecto.Migration

  def up do
    alter table(:areas) do
      add(:key, :string)
    end

    create(index(:areas, [:key]))
  end

  def down do
    alter table(:areas) do
      remove(:key)
    end

    drop_if_exists(index(:maps, [:key]))
  end
end
