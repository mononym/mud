defmodule Mud.Engine.Middleware do
  @callback execute(Mud.Engine.Command.ExecutionContext.t()) ::
              Mud.Engine.Command.ExecutionContext.t()
end
