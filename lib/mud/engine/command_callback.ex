defmodule Mud.Engine.CommandCallback do
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
      @behaviour Mud.Engine.CommandCallback

      import Mud.Engine.Command.ExecutionContext

      @doc false
      def parse_arg_string(raw_args), do: {:ok, String.trim(raw_args)}

      @doc false
      def type(), do: "basic"

      defoverridable parse_arg_string: 1,
                     type: 0
    end
  end

  @doc """
  Called when the Engine is checking if the callback module can handle the
  """
  @callback parse_arg_string(String.t()) :: {:ok, term} | {:error, error}

  @doc """
  Called when the Engine determines the Command should be executed. This means all the matching, parsing, and
  permissions checks have passed. This is called after 'parse_args/1', assuming there was no error.

  An execution context is passed to the callback function, populated with several helpful bits of information to aid in
  the execution of the command. See 'Exmud.Engine.Command.ExecutionContext'.
  """
  @callback execute(context) :: context

  @doc """
  The type of command it is.

  Current types are: basic, combat
  """
  @callback type() :: String.t()

  @typedoc "An error message."
  @type error :: term

  @typedoc "An execution context providing the required information to execute a command."
  @type context :: %Mud.Engine.Command.ExecutionContext{}
end
