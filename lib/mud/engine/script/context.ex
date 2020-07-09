defmodule Mud.Engine.Script.Context do
  @moduledoc """
  Contains contains everything required for the running of a Script.
  """

  alias Mud.Engine.Event
  alias Mud.Engine.Message

  @type character() :: Mud.Engine.Character.t()
  @type character_id() :: String.t()
  @type error_message() :: String.t()
  @type message() :: Mud.Engine.Message.Input.t() | Mud.Engine.Message.Output.t()
  @type messages() :: [message()]
  @type terminate_session() :: boolean()
  @type context() :: __MODULE__.t()
  @type thing ::
          Mud.Engine.Area.t()
          | Mud.Engine.Character.t()
          | Mud.Engine.Item.t()
          | Mud.Engine.Link.t()
          | Mud.Engine.Region.t()

  use TypedStruct

  typedstruct do
    field(:key, String.t(), required: true)
    field(:callback_module, module(), required: true)
    field(:state, map(), default: %{})
    field(:thing, thing(), required: true)
    field(:timer_ref, term())
    field(:next_iteration, integer(), default: 6_000)
    field(:halt, boolean(), default: false)

    # Flag to help with attaching/loading data
    field(:initialized, boolean(), default: false)

    # Only checked/used in the case where halt has been explicitly set to true. Detaches a script from its thing
    # and deletes all data
    field(:detach, boolean(), default: false)

    # arbitrary error returned from a function call.
    field(:error, term())

    # arbitrary passed in args used for things like start. Reset after being used in a callback function.
    field(:args, term())

    # arbitrary response for the cases where it is possible. Reset after being used for a return from a callback function.
    field(:response, term())

    # Messages to be sent upon successful execution of logic. Processed/cleared after every callback call.
    field(:messages, [Mud.Engine.Message.Input.t() | Mud.Engine.Message.Output.t()], default: [])

    # Events to be sent upon successful execution of logic. Processed/cleared after every callback call.
    field(:events, [struct()], default: [])
  end

  @doc """
  Set the number of milliseconds to wait for the next run
  """
  @spec append_message(context, integer) :: context
  def next(context, time) do
    %{context | next_iteration: time}
  end

  @doc """
  Tell the script to halt
  """
  @spec halt(context) :: context
  def halt(context) do
    %{context | halt: true}
  end

  @doc """
  Tell the script to detach
  """
  @spec detach(context) :: context
  def detach(context) do
    %{context | detach: true}
  end

  @doc """
  Append a message to the list of messages which will be sent after the command has been executed
  """
  @spec append_message(context, message) :: context
  def append_message(%__MODULE__{} = context, message) do
    %{context | messages: [message | context.messages]}
  end

  @doc """
  Append a message to the list of messages which will be sent after the command has been executed
  """
  @spec append_output(
          context :: %__MODULE__{},
          to :: String.t() | [String.t()],
          message :: String.t(),
          tag :: String.t()
        ) :: context
  def append_output(%__MODULE__{} = context, to, message, tag) do
    msg =
      Message.new_output(
        to,
        message,
        tag
      )

    append_message(context, msg)
  end

  @doc """
  Append an error, to be sent to the character, to the context.
  """
  @spec append_error(
          context :: %__MODULE__{},
          message :: String.t()
        ) :: context
  def append_error(%__MODULE__{} = context, message) do
    append_output(
      context,
      context.thing.id,
      message,
      "error"
    )
  end

  @doc """
  Append an event to the list of events which will be sent after the command has been executed
  """
  @spec append_event(
          context :: %__MODULE__{},
          to :: String.t() | [String.t()],
          event :: struct()
        ) :: context
  def append_event(%__MODULE__{} = context, to, event) do
    append_event(context, Event.new(to, event))
  end

  @doc """
  Append an event to the list of events which will be sent after the command has been executed
  """
  @spec append_event(context :: %__MODULE__{}, event :: Mud.Engine.Event.t()) :: context
  def append_event(%__MODULE__{} = context, event) do
    %{context | events: [event | context.events]}
  end

  @doc """
  Clear the events in the context.
  """
  @spec clear_events(context) :: context
  def clear_events(%__MODULE__{} = context) do
    %{context | events: []}
  end

  @doc """
  Put a value into the data embedded in the Context, returning the updated Context.
  """
  @spec set_messages(context, messages) :: context
  def set_messages(%__MODULE__{} = context, messages) do
    %{context | messages: messages}
  end

  @doc """
  Get a value from Context.
  """
  @spec get_messages(context) :: messages
  def get_messages(%__MODULE__{} = context) do
    context.messages
  end

  @doc """
  Put an error into the Context, returning the updated Context.
  """
  @spec put_error(context, error :: term()) :: context
  def put_error(%__MODULE__{} = context, error) do
    %{context | error: error}
  end

  @doc """
  Put a value into the data embedded in the Context, returning the updated Context.
  """
  @spec put_state(context, key :: term(), value :: term()) :: context
  def put_state(%__MODULE__{} = context, key, value) do
    %{context | state: Map.put(context.state, key, value)}
  end

  @doc """
  Get a value from the data embedded in the Context.
  """
  @spec get_state(context, key :: term()) :: term()
  def get_state(%__MODULE__{} = context, key) do
    context.state[key]
  end

  @doc """
  Clear the messages in the context.
  """
  @spec clear_messages(context) :: context
  def clear_messages(%__MODULE__{} = context) do
    %{context | messages: []}
  end

  @doc """
  Put args into the context.
  """
  @spec put_args(context, args :: term()) :: context
  def put_args(%__MODULE__{} = context, args) do
    %{context | args: args}
  end

  @doc """
  Clear the args in the context.
  """
  @spec clear_args(context) :: context
  def clear_args(%__MODULE__{} = context) do
    %{context | args: nil}
  end

  @doc """
  Put response into the context.
  """
  @spec put_response(context, response :: term()) :: context
  def put_response(%__MODULE__{} = context, response) do
    %{context | response: response}
  end

  @doc """
  Clear the response in the context.
  """
  @spec clear_response(context) :: context
  def clear_response(%__MODULE__{} = context) do
    %{context | response: nil}
  end
end
