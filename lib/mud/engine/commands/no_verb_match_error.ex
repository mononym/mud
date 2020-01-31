defmodule Mud.Engine.Command.NoVerbMatchError do
  use Mud.Engine.CommandCallback

  def execute(context) do
    context
    |> append_message(%Mud.Engine.OutputMessage{
      character_id: context.character_id,
      text: "Could not determine which action you wished to take. Please be more specific."
    })
  end
end
