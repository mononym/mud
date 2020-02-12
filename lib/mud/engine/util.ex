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
end
