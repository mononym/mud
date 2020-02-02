defmodule Mud.Engine.Middleware.SendMessages do
  @behaviour Mud.Engine.Middleware

  @impl true
  def execute(%Mud.Engine.Command.ExecutionContext{} = context) do
    Enum.each(context.messages, fn message ->
      Mud.Engine.cast_message_to_character_session(message)
    end)

    context
  end
end
