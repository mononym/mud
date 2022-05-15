defmodule Mud.Engine.Command.Context do
  @moduledoc """
  A CommandContext struct contains everything required for the processing of a Command.
  The context is intended to be passed between multiple middlewares, some of which may need to run before others to
  populate required data.
  """

  alias Mud.Engine.Event
  alias Mud.Engine.Message

  @type character() :: Mud.Engine.Character.t()
  @type character_id() :: String.t()
  @type command() :: Mud.Engine.Command.t()
  @type continuation_command() :: command()
  @type continuation_data() :: map()
  @type continuation_module() :: module()
  @type continuation_type() :: atom()
  @type error_message() :: String.t()
  @type input() :: String.t() | map()
  @type is_continuation() :: boolean()
  @type message() ::
          Mud.Engine.Message.Input.t()
          | Mud.Engine.Message.Output.t()
          | Mud.Engine.Message.StoryOutput.t()
  @type messages() :: [message()]
  @type terminate_session() :: boolean()
  @type context() :: __MODULE__.t()

  use TypedStruct

  typedstruct do
    # The ID of the input which triggered this execution
    field(:id, String.t())
    # The populated Command struct
    field(:command, Mud.Engine.Command.t())

    # The Character that the command is being processed for. Will be populated immediatly before execution, in the
    # transaction.
    field(:character, Mud.Engine.Character.t())

    # Id of the character the command is being processed for.
    field(:character_id, String.t())

    # Messages to be sent upon successful execution of logic.
    field(
      :messages,
      [
        Mud.Engine.Message.Input.t()
        | Mud.Engine.Message.Output.t()
        | Mud.Engine.Message.StoryOutput.t()
      ],
      default: []
    )

    # Events to be sent upon successful execution of logic.
    field(:events, [struct()], default: [])

    # The raw text input before any processing.
    field(:input, String.t(), required: true)

    # A special flag that can be returned by any command which signals the character session to close.
    field(:terminate_session, boolean(), default: false)

    # The command that was processed the first time around.
    field(:continuation_command, Mud.Engine.Command.t())

    # Data which is preserved between the initial/continuing calls of a single command. Can be used to carry
    # information over such as the objects that are being selected from. For example, if the 'look' command returns a
    # list of 5 items, the exact item to be looked at should be preserved between commands so that if the player enters
    # '1' the command can be applied correctly.
    field(:continuation_data, map(), default: %{})

    # Flag whether or not this is a continuation of a previous command execution.
    field(:is_continuation, boolean(), default: false)

    # The callback module to call on continuation.
    field(:continuation_module, module())

    # The type of continuiation it is, such as numeric. Meaning a number being entered continues while anything else is
    # executed as is instead while the continuation data is dropped.
    field(:continuation_type, atom())
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
      context.character.id,
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
  Set the flag that signals the session to close after post processing has finished.
  """
  @spec terminate_session(context, boolean) :: context
  def terminate_session(%__MODULE__{} = context, terminate \\ true) when is_boolean(terminate) do
    %{context | terminate_session: terminate}
  end

  @doc """
  Delete a value from the data embedded in the Context.
  """
  @spec clear_continuation_data(context) :: context
  def clear_continuation_data(%__MODULE__{} = context) do
    %{context | continuation_data: %{}}
  end

  @doc """
  Get a value from Context.
  """
  @spec get_continuation_data(context) :: any
  def get_continuation_data(%__MODULE__{} = context) do
    context.continuation_data
  end

  @doc """
  Get a value from Context.
  """
  @spec get_from_continuation_data(context, any) :: any
  def get_from_continuation_data(%__MODULE__{} = context, key) do
    Map.get(context.continuation_data, key)
  end

  @doc """
  Put a value into the data embedded in the Context, returning the updated Context.
  """
  @spec set_continuation_data(context, any) :: context
  def set_continuation_data(%__MODULE__{} = context, data) do
    %{context | continuation_data: data}
  end

  @doc """
  Put a value into the data embedded in the Context, returning the updated Context.
  """
  @spec set_character(context, any) :: context
  def set_character(%__MODULE__{} = context, character) do
    %{context | character: character}
  end

  @spec get_character(context) :: character()
  @doc """
  Get a value from Context.
  """
  def get_character(%__MODULE__{} = context) do
    context.character
  end

  @doc """
  Put a value into the data embedded in the Context, returning the updated Context.
  """
  def set_command(%__MODULE__{} = context, command) do
    %{context | command: command}
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
  Put a value into the data embedded in the Context, returning the updated Context.
  """
  @spec set_input(context, any) :: context
  def set_input(%__MODULE__{} = context, data) do
    %{context | input: data}
  end

  @doc """
  Flag whether or not this context is for a continuiation
  """
  @spec set_is_continuation(context, boolean) :: context
  def set_is_continuation(context, value \\ false) do
    %{context | is_continuation: value}
  end

  @doc """
  Put a value into the data embedded in the Context, returning the updated Context.
  """
  @spec set_continuation_module(context, module) :: context
  def set_continuation_module(%__MODULE__{} = context, module) do
    %{context | continuation_module: module}
  end

  @doc """
  Put a value into the data embedded in the Context, returning the updated Context.
  """
  @spec set_continuation_type(context, atom) :: context
  def set_continuation_type(%__MODULE__{} = context, type) do
    %{context | continuation_type: type}
  end

  @doc """
  Put a value into the data embedded in the Context, returning the updated Context.
  """
  @spec set_continuation_command(context, command) :: context
  def set_continuation_command(%__MODULE__{} = context, command) do
    %{context | continuation_command: command}
  end

  @doc """
  Get a value from Context.
  """
  @spec get_continuation_command(context) :: command
  def get_continuation_command(%__MODULE__{} = context) do
    context.continuation_command
  end

  @doc """
  Clear a value in the Context.
  """
  @spec clear_continuation_module(context) :: context
  def clear_continuation_module(%__MODULE__{} = context) do
    %{context | continuation_module: nil}
  end

  @doc """
  Clear all of the continuation values in the Context.
  """
  @spec clear_continuation(context) :: context
  def clear_continuation(%__MODULE__{} = context) do
    %{
      context
      | continuation_data: %{},
        continuation_module: nil,
        continuation_type: nil,
        is_continuation: false
    }
  end
end
