defmodule Mud.Engine.CharactersShops do
  use Mud.Schema
  import Ecto.Query

  @primary_key false
  schema "characters_shops" do
    belongs_to(:character, Mud.Engine.Character, type: :binary_id)
    belongs_to(:shop, Mud.Engine.Shop, type: :binary_id)

    timestamps()
  end

  @doc """
  Given a character id which to check, returns a query which returns the ids of the known shops
  """
  def known_shop_ids_from_character_id_query(character_id) do
    from(character_shop in __MODULE__,
      where: character_shop.character_id == ^character_id,
      select: character_shop.shop_id
    )
  end
end
