defmodule Mud.Engine.CharactersAreas do
  use Mud.Schema

  @primary_key false
  schema "characters_areas" do
    belongs_to(:character, Mud.Engine.Character, type: :binary_id)
    belongs_to(:area, Mud.Engine.Area, type: :binary_id)

    timestamps()
  end
end
