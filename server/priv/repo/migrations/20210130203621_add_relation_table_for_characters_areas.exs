defmodule Mud.Repo.Migrations.AddRelationTableForCharactersAreas do
  use Ecto.Migration

  def change do
    create table(:characters_areas, primary_key: false) do
      add(
        :character_id,
        references(:characters, on_delete: :delete_all, type: :binary_id)
      )

      add(
        :area_id,
        references(:areas, on_delete: :delete_all, type: :binary_id)
      )

      timestamps()
    end

    create(index(:characters_areas, [:character_id]))
    create(index(:characters_areas, [:area_id]))

    create(
      unique_index(:characters_areas, [:character_id, :area_id],
        name: :character_id_area_id_unique_index
      )
    )
  end
end
