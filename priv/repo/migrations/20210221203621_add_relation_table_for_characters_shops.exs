defmodule Mud.Repo.Migrations.AddRelationTableForCharactersShops do
  use Ecto.Migration

  def change do
    create table(:characters_shops, primary_key: false) do
      add(
        :character_id,
        references(:characters, on_delete: :delete_all, type: :binary_id)
      )

      add(
        :shop_id,
        references(:shops, on_delete: :delete_all, type: :binary_id)
      )

      timestamps()
    end

    create(index(:characters_shops, [:character_id]))
    create(index(:characters_shops, [:shop_id]))

    create(
      unique_index(:characters_shops, [:character_id, :shop_id],
        name: :character_id_shop_id_unique_index
      )
    )
  end
end
