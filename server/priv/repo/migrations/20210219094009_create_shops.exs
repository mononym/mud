defmodule Mud.Repo.Migrations.CreateShops do
  use Ecto.Migration

  def change do
    create table(:shops, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:area_id, references(:areas, on_delete: :delete_all, type: :binary_id))

      add(:name, :citext)
    end

    create(index(:shops, [:name]))
    create(index(:shops, [:area_id]))
  end
end
