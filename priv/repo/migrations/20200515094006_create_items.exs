defmodule Mud.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:is_furniture, :boolean)
      add(:is_scenery, :boolean)
      add(:is_container, :boolean)
      add(:is_hidden, :boolean)
      add(:count, :integer)
      add(:glance_description, :string)
      add(:look_description, :string)

      add(:area_id, references(:areas, on_delete: :nilify_all, type: :binary_id))
      add(:character_id, references(:characters, on_delete: :nilify_all, type: :binary_id))
    end

    create(index(:items, [:is_furniture]))
    create(index(:items, [:is_scenery]))
    create(index(:items, [:is_container]))
    create(index(:items, [:is_hidden]))
    create(index(:items, [:count]))
  end
end
