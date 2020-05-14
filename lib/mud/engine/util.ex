defmodule Mud.Engine.Util do
  @moduledoc """
  Helper functions.
  """

  import Mud.Engine.Command.ExecutionContext

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

  @spec multiple_match_error(
          command_context :: CommandContext.t(),
          keys :: [String.t()],
          values :: [String.t()],
          error_message :: String.t(),
          continuation_module :: module()
        ) :: CommandContext.t()
  def multiple_match_error(context, keys, values, error_message, continuation_module) do
    indexed_values = Mud.Util.list_to_index_map(values)

    context
    |> append_message(
      output(
        context.character_id,
        error_message,
        keys
      )
    )
    |> set_is_continuation(true)
    |> set_continuation_data(indexed_values)
    |> set_continuation_module(continuation_module)
    |> set_continuation_type(:numeric)
    |> set_success()
  end
end
