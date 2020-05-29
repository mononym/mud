defmodule Mud.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items, primary_key: false) do
      timestamps()
      add(:id, :binary_id, primary_key: true)
      add(:is_furniture, :boolean)
      add(:is_scenery, :boolean)
      add(:is_hidden, :boolean)
      add(:glance_description, :string)
      add(:look_description, :string)

      add(:area_id, references(:areas, on_delete: :nilify_all, type: :binary_id))

      ##
      #
      # Container Component
      #
      ##

      add(:is_container, :boolean, default: false)
      add(:container_closeable, :boolean, default: false)
      add(:container_open, :boolean, default: false)
      add(:container_lockable, :boolean, default: false)
      add(:container_locked, :boolean, default: false)
      add(:container_length, :integer, default: 0)
      add(:container_width, :integer, default: 0)
      add(:container_height, :integer, default: 0)
      add(:container_capacity, :integer, default: 0)

      ##
      #
      # Wearable Component
      #
      ##

      add(:is_wearable, :boolean, default: false)
      add(:wearable_is_worn, :boolean, default: false)
      add(:wearable_location, :citext)
      add(:wearable_worn_by_id, references(:characters, on_delete: :nilify_all, type: :binary_id))
    end

    create(index(:items, [:is_furniture]))
    create(index(:items, [:is_scenery]))
    create(index(:items, [:is_hidden]))

    ##
    #
    # Container Component
    #
    ##

    create(index(:items, [:is_container]))
    create(index(:items, [:container_closeable]))
    create(index(:items, [:container_open]))
    create(index(:items, [:container_lockable]))
    create(index(:items, [:container_locked]))
    create(index(:items, [:container_length]))
    create(index(:items, [:container_width]))
    create(index(:items, [:container_height]))

    ##
    #
    # Wearable Component
    #
    ##

    create(index(:items, [:is_wearable]))
    create(index(:items, [:wearable_is_worn]))
    create(index(:items, [:wearable_location]))
    create(index(:items, [:wearable_worn_by_id]))
  end
end
