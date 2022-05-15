defmodule Mud.Repo.Migrations.LinkAreaWithMap do
  use Ecto.Migration

  def change do
    alter table(:areas) do
      add(:map_id, references(:maps, on_delete: :nilify_all, type: :binary_id))
    end

    create(index(:areas, [:map_id]))
  end
end
