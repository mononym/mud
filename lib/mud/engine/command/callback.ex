defmodule Mud.Engine.Command.Callback do
  @moduledoc """
  A callback module for commands.

  Commands must implement two callbacks, parse_args/1 and execute/1
  """

  #
  # Behavior definition and default callback setup
  #

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      @behaviour Mud.Engine.Command.Callback

      @doc false
      def continue(_context), do: raise("Callback continue/1 not implemented for #{__MODULE__}")

      @doc false
      def execute(_context), do: raise("Callback execute/1 not implemented for #{__MODULE__}")

      defoverridable continue: 1,
                     execute: 1
    end
  end

  @doc """
  Called when the Engine determines the Command should be executed. This means all the matching, parsing, and
  permissions checks have passed. This is called after 'parse_arg_string/1', assuming there was no error.

  An execution context is passed to the callback function, populated with several helpful bits of information to aid in
  the execution of the command. See 'Exmud.Engine.CommandContext'.
  """
  @callback execute(context) :: context

  @doc """
  Continue the execution of a command.

  If for some reason the execution is paused, for example to prompt for additional user input, this will be called upon
  next input to continue execution.
  """
  @callback continue(context) :: context

  @typedoc "An execution context providing the required information to execute a command."
  @type context :: %Mud.Engine.Command.Context{}
end
