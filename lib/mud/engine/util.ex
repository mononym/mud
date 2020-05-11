defmodule Mud.Engine.Util do
  @moduledoc """
  Helper functions.
  """

  import Mud.Engine.CommandContext

  def output(who, text, table_data \\ nil) do
    %Mud.Engine.Output{
      id: UUID.uuid4(),
      character_id: who,
      text: text,
      table_data: table_data
    }
  end

  def clear_continuation_from_context(context) do
    context
    |> clear_continuation_data()
    |> clear_continuation_module()
    |> set_is_continuation(false)
  end

  def multiple_link_error(context, command, items, strings, error_message, continuation_module) do
    items =
      items
      |> Enum.map(&(command <> " " <> &1.text))
      |> Mud.Util.list_to_index_map()

    context
    |> append_message(
      output(
        context.character_id,
        error_message,
        strings
      )
    )
    |> set_is_continuation(true)
    |> set_continuation_data(items)
    |> set_continuation_module(continuation_module)
    |> set_continuation_type(:numeric)
    |> set_success()
  end
end
