defmodule Mud.Engine.Command.History do
  use Mud.Engine.CommandCallback

  def execute(context) do
    context
    |> append_message(%Mud.Engine.Output{
      id: UUID.uuid4(),
      character_id: context.character_id,
      text: "{{error}}The logic for this verb has not been implemented yet.{{/error}}"
    })
    |> set_success(true)
  end
end
