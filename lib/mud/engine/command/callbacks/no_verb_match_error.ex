defmodule Mud.Engine.Command.NoVerbMatchError do
  use Mud.Engine.Command.Callback

  def execute(context) do
    context
    |> append_message(%Mud.Engine.Output{
      id: UUID.uuid4(),
      character_id: context.character_id,
      text:
        "{{error}}Could not determine which action you wished to take. Please be more specific.{{/error}}"
    })
  end
end
