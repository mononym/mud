defmodule Mud.Engine.CharactersMaps do
  use Mud.Schema

  @primary_key false
  schema "characters_maps" do
    belongs_to(:character, Mud.Engine.Character, type: :binary_id)
    belongs_to(:map, Mud.Engine.Map, type: :binary_id)

    timestamps()
  end
end
