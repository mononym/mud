defmodule Mud.Engine.Command.Placeholder do
  use Mud.Engine.CommandCallback

  def execute(context) do
    context
    |> append_message(%Mud.Engine.OutputMessage{
      character_id: context.character_id,
      text: "The logic for this verb has not been implemented yet."
    })
    |> set_success(true)
  end
end
