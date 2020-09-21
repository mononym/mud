defmodule Mud.Repo.Migrations.AddSlugToCharacters do
  use Ecto.Migration

  def change do
    alter table(:characters) do
      add(:slug, :string)
    end

    create(unique_index(:characters, [:slug]))
  end
end
