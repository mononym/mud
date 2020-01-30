defmodule Mud.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:type, :string)
      add(:text, :string)
      add(:from_id, references(:areas, on_delete: :delete_all))
      add(:to_id, references(:areas, on_delete: :delete_all))

      timestamps()
    end

    create(index(:links, [:from_id]))
    create(index(:links, [:to_id]))
    create(unique_index(:links, [:type, :from_id, :to_id]))
  end
end
