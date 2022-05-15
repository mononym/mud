defmodule Mud.Repo.Migrations.AddPictureToProfile do
  use Ecto.Migration

  def down do
    alter table(:profiles) do
      remove(:picture)
      add(:slug, :string)
    end

    create(index(:profiles, [:slug]))
  end

  def up do
    alter table(:profiles) do
      add(:picture, :string)
      remove(:slug)
    end
  end
end
