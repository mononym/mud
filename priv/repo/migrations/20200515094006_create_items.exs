defmodule Mud.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:is_furniture, :boolean)
      add(:is_scenery, :boolen)
      add(:is_container, :boolen)
      add(:count, :integer)
      add(:glance_description, :string)
      add(:look_description, :string)

      add(:area_id, references(:areas, on_delete: :nilify_all, type: :binary_id))
      add(:character_id, references(:characters, on_delete: :nilify_all, type: :binary_id))
    end

    create(index(:links, [:is_furniture]))
    create(index(:links, [:is_scenery]))
    create(index(:links, [:is_container]))
  end
end
