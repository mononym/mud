defmodule Mud.Repo.Migrations.CreateCharacters do
  use Ecto.Migration

  def change do
    create table(:characters, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string)
      add(:location_id, references(:areas, on_delete: :nilify_all))
      add(:player_id, references(:players, on_delete: :nothing, type: :binary_id))

      timestamps()
    end

    create(index(:characters, [:location]))
    create(index(:characters, [:player_id]))
    create(index(:characters, [:location_id]))
  end
end
