defmodule Mud.Engine.Command.History do
  use Mud.Engine.CommandCallback

  def execute(context) do
    context.character_id
    |> Mud.Engine.Session.get_history()
    |> Enum.reduce(context, fn entry, cxt ->
      append_message(cxt, entry)
    end)
    |> set_success(true)
  end
end
