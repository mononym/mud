defmodule Mud.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items, primary_key: false) do
      timestamps()
      add(:id, :binary_id, primary_key: true)
      add(:is_furniture, :boolean)
      add(:is_scenery, :boolean)
      add(:is_hidden, :boolean)
      add(:short_description, :string)
      add(:long_description, :string)
      add(:icon, :string)

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
      add(:container_primary, :boolean, default: false)
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

      ##
      #
      # Holdable Component
      #
      ##

      add(:is_holdable, :boolean, default: false)
      add(:holdable_is_held, :boolean, default: false)
      add(:holdable_hand, :citext)
      add(:holdable_held_by_id, references(:characters, on_delete: :nilify_all, type: :binary_id))

      ##
      #
      # Physical Component
      #
      ##

      add(:is_physical, :boolean, default: false)
      add(:physical_length, :integer, default: 1)
      add(:physical_height, :integer, default: 1)
      add(:physical_width, :integer, default: 1)
      add(:physical_weight, :integer, default: 1)
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
    create(index(:items, [:container_primary]))

    ##
    #
    # Wearable Component
    #
    ##

    create(index(:items, [:is_wearable]))
    create(index(:items, [:wearable_is_worn]))
    create(index(:items, [:wearable_location]))
    create(index(:items, [:wearable_worn_by_id]))

    ##
    #
    # Holdable Component
    #
    ##

    create(index(:items, [:is_holdable]))
    create(index(:items, [:holdable_is_held]))
    create(index(:items, [:holdable_hand]))
    create(index(:items, [:holdable_held_by_id]))

    ##
    #
    # Physical Component
    #
    ##

    create(index(:items, [:is_physical]))
    create(index(:items, [:physical_length]))
    create(index(:items, [:physical_height]))
    create(index(:items, [:physical_width]))
    create(index(:items, [:physical_weight]))
  end
end
