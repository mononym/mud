defmodule Mud.Engine.Command.MultipleVerbMatchError do
  use Mud.Engine.CommandCallback

  def execute(context) do
    context
    |> append_message(%Mud.Engine.Output{
      id: UUID.uuid4(),
      character_id: context.character_id,
      text:
        "{{error}}Could not determine which action (#{context.matched_verb}) you wished to take. Please be more specific.{{/error}}"
    })
  end
end
