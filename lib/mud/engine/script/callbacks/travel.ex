defmodule Mud.Engine.Script.Travel do
  use Mud.Engine.Script.Callback

  def initialize(context) do
    IO.inspect(context, label: :travel_script_initialize)
    IO.inspect(context.args, label: :travel_script_initialize)
    put_state(context, :path, context.args)
  end

  def run(context) do
    IO.inspect(context, label: :travel_script_run)
    IO.inspect(context.state, label: :travel_script_run)

    # what is the logic of the travel script?
    

    context
    |> halt()
    |> detach()
  end
end
