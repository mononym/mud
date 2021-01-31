defmodule Mud.Engine.CharactersAreas do
  use Mud.Schema
  import Ecto.Query

  @primary_key false
  schema "characters_areas" do
    belongs_to(:character, Mud.Engine.Character, type: :binary_id)
    belongs_to(:area, Mud.Engine.Area, type: :binary_id)

    timestamps()
  end

  @doc """
  Given a subquery which returns a list of Area ids to check, returns a query which returns the ids of the explored
  areas for a character.
  """
  def explored_ids_from_area_ids_subquery(area_ids_subquery, character_id) do
    from(character_area in __MODULE__,
      where:
        character_area.area_id in subquery(area_ids_subquery) and
          character_area.character_id == ^character_id,
      select: character_area.area_id
    )
  end
end
