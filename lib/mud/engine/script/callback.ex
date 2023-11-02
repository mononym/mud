defmodule Mud.Engine.Script.Callback do
  @moduledoc """
  A callback module for scripts.

  Commands must implement two callbacks, parse_args/1 and execute/1
  """

  #
  # Behavior definition and default callback setup
  #

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      @behaviour Mud.Engine.Script.Callback
      alias Mud.Engine.Script.Result
      import Mud.Engine.Script.Context

      @doc false
      def handle_message(context, message), do: context

      @doc false
      def initialize(context), do: context

      @doc false
      def run(context), do: context

      @doc false
      def start(context), do: context

      @doc false
      def stop(context), do: context

      defoverridable handle_message: 2,
                     initialize: 1,
                     run: 1,
                     start: 1,
                     stop: 1
    end
  end

  #
  # Behavior definition and default callback setup
  #

  @doc """
  Handle a message which has been explicitly sent to the Script.
  """
  @callback handle_message(context, message) :: context

  @doc """
  Called the first, and only the first, time a Script is started on an Object. Or in the case of duplicate Scripts, once
  per Script callback_module/Dedupe Key combination.

  If called, it will immediately precede `start/2` and the returned state will be passed to the `start/2` callback. If a
  Script has been previously initialized, the persisted state is loaded from the database and used in the `start/2`
  callback instead.
  """
  @callback initialize(context) :: context

  @doc """
  Called in response to an interval period expiring, or an explicit call to run the Script again. Unlike Systems, a
  Script is always expected to be running.
  """
  @callback run(context) :: context

  @doc """
  Called when the Script is being started.

  If this is the first time the Script has been started it will immediately follow a call to 'initialize/2' and will be
  called with the state returned from the previous call, otherwise the state will be loaded from the database and used
  instead. Must return a new state.
  """
  @callback start(context) :: context

  @doc """
  Called when the Script is being stopped.

  Must return a new state which will be persisted.
  """
  @callback stop(context) :: context

  @typedoc "An execution context providing the required information to execute a script."
  @type context :: %Mud.Engine.Script.Context{}

  @typedoc "Arguments passed through to a callback module."
  @type args :: term

  @typedoc "A message passed through to a callback module."
  @type message :: term

  @typedoc "How many milliseconds should pass until the run callback is called again."
  @type next_iteration :: integer

  @typedoc "A reply passed through to the caller."
  @type reply :: term

  @typedoc "An error message passed through to the caller."
  @type error :: term

  @typedoc "The reason the Script is stopping."
  @type reason :: term

  @typedoc "State used by the callback module."
  @type state :: term

  @type thing ::
          Mud.Engine.Area.t()
          | Mud.Engine.Character.t()
          | Mud.Engine.Item.t()
          | Mud.Engine.Link.t()
          | Mud.Engine.Region.t()

  @typedoc "Each script has a key which, when combined witn an ID, is what is used as the PK"
  @type key :: String.t()

  @typedoc "Type of thing the Script is being attached to. Area/character/item/link"
  @type thing_type :: String.t()

  @typedoc "The callback_module that is the implementation of the Script logic."
  @type callback_module :: atom
end
