defmodule Mud.Repo.Migrations.AddRelationTableForCharactersMaps do
  use Ecto.Migration

  def change do
    create table(:characters_maps, primary_key: false) do
      add(
        :character_id,
        references(:characters, on_delete: :delete_all, type: :binary_id)
      )

      add(
        :map_id,
        references(:maps, on_delete: :delete_all, type: :binary_id)
      )

      timestamps()
    end

    create(index(:characters_maps, [:character_id]))
    create(index(:characters_maps, [:map_id]))

    create(
      unique_index(:characters_maps, [:character_id, :map_id],
        name: :character_id_map_id_unique_index
      )
    )
  end
end
