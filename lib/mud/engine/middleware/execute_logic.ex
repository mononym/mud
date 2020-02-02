defmodule Mud.Engine.Middleware.ExecuteLogic do
  @behaviour Mud.Engine.Middleware

  @impl true
  def execute(%Mud.Engine.Command.ExecutionContext{} = context) do
    {:ok, args} = context.callback_module.parse_arg_string(context.raw_argument_string)
    context = %{context | parsed_args: args}

    {:ok, context} =
      Mud.Repo.transaction(fn ->
        context.callback_module.execute(context)
      end)

    context
  end
end
