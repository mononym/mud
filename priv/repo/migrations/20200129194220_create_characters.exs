defmodule Mud.Repo.Migrations.CreateCharacters do
  use Ecto.Migration

  def change do
    create table(:characters) do
      add(:name, :string)
      add(:location, references(:areas, on_delete: :nothing))
      add(:player, references(:players, on_delete: :nothing, type: :binary_id))

      timestamps()
    end

    create(index(:characters, [:location]))
    create(index(:characters, [:player]))
  end
end
