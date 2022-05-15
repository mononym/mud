defmodule Mud.Repo.Migrations.RemoveSlugFromCharacter do
  use Ecto.Migration

  def down do
    alter table(:characters) do
      add(:slug, :string)
    end

    create(index(:characters, [:slug]))
  end

  def up do
    alter table(:characters) do
      remove(:slug)
    end
  end
end
