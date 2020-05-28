defmodule Mud.Repo.Migrations.CreateItemSelfReference do
  use Ecto.Migration

  def change do
    alter table(:items) do
      ##
      #
      # Container Component
      #
      ##
      add(:container_id, references(:items, on_delete: :nilify_all, type: :binary_id))
    end

    ##
    #
    # Container Component
    #
    ##

    create(index(:items, [:container_id]))
  end
end
