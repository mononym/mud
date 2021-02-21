defmodule Mud.Repo.Migrations.AddDescriptionToShops do
  use Ecto.Migration

  def change do
    alter table(:shops) do
      add(:description, :citext)
    end

    create(index(:shops, [:description]))
  end
end
