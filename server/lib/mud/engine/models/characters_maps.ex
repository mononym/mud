defmodule Mud.Engine.CharactersMaps do
  use Mud.Schema

  @primary_key false
  schema "characters_maps" do
    field(:character_id, :binary_id)
    field(:map_id, :binary_id)

    timestamps()
  end
end
