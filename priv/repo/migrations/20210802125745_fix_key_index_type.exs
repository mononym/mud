defmodule Mud.Repo.Migrations.FixKeyIndexType do
  use Ecto.Migration

  def up do
    drop_if_exists(index(:maps, [:key]))
    create(unique_index(:maps, [:key]))
  end

  def down do
    drop_if_exists(index(:maps, [:key]))
    create(index(:maps, [:key]))
  end
end
