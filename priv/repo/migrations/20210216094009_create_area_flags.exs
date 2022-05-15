defmodule Mud.Repo.Migrations.CreateAreaFlags do
  use Ecto.Migration

  def change do
    create table(:area_flags, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:area_id, references(:areas, on_delete: :delete_all, type: :binary_id))

      add(:bank, :boolean, default: false)
    end

    create(index(:area_flags, [:bank]))
    create(unique_index(:area_flags, [:area_id]))
  end
end
