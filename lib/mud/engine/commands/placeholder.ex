defmodule Mud.Engine.Command.Placeholder do
  use Mud.Engine.CommandCallback

  def execute(context) do
    context
    |> append_message(
      Mud.Engine.Message.new(
        context.player_id,
        context.character_id,
        "The logic for this verb has not been implemented yet.",
        :output
      )
    )
    |> set_success(true)
  end
end
