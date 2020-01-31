defmodule Mud.Engine.Command.MultipleVerbMatchError do
  use Mud.Engine.CommandCallback

  def execute(context) do
    context
    |> append_message(
      Mud.Engine.Message.new(
        context.player_id,
        context.character_id,
        "Could not determine which action (#{context.matched_verb}) you wished to take. Please be more specific.",
        :output
      )
    )
  end
end
