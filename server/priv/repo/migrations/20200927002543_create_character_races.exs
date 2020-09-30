defmodule Mud.Repo.Migrations.CreateCharacterRaces do
  use Ecto.Migration

  def change do
    create table(:character_races, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :singular, :string
      add :plural, :string
      add :adjective, :string
      add :portrait, :string
      add :description, :string
      add :instance_id, references(:instances, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:character_races, [:instance_id])
    create unique_index(:character_races, [:singular])
    create unique_index(:character_races, [:plural])
    create unique_index(:character_races, [:adjective])
  end
end
