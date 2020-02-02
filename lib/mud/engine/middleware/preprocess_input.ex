defmodule Mud.Engine.Middleware.PreprocessInput do
  @behaviour Mud.Engine.Middleware

  @impl true
  def execute(%Mud.Engine.Command.ExecutionContext{} = context) do
    [raw_verb, raw_argument_string] =
      case String.split(context.raw_input, " ", parts: 2, trim: true) do
        [verb, arg_string] ->
          [String.downcase(verb), arg_string]

        [verb] ->
          [String.downcase(verb), ""]
      end

    %{context | raw_verb: raw_verb, raw_argument_string: raw_argument_string}
  end
end
