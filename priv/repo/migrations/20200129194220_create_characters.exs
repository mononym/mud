defmodule Mud.Repo.Migrations.CreateCharacters do
  use Ecto.Migration

  def change do
    create table(:characters, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :citext)
      add(:slug, :citext)
      add(:player_id, references(:players, on_delete: :nothing, type: :binary_id))
    end

    create(index(:characters, [:player_id]))
    create(unique_index(:characters, [:name]))
    create(unique_index(:characters, [:slug]))
    execute("CREATE INDEX name_tgm_idx ON characters USING GIN (name gin_trgm_ops)")
  end
end
