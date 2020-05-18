defmodule Mud.Engine.Command.ExecutionContext do
  @moduledoc """
  A CommandContext struct contains everything required for the processing of a Command.
  The context is intended to be passed between multiple middlewares, some of which may need to run before others to
  populate required data.
  """

  @type character() :: Mud.Engine.Model.Character.t()
  @type character_id() :: String.t()
  @type command() :: Mud.Engine.Command.t()
  @type continuation_command() :: command()
  @type continuation_data() :: map()
  @type continuation_module() :: module()
  @type continuation_type() :: atom()
  @type error_message() :: String.t()
  @type input() :: String.t() | map()
  @type is_continuation() :: boolean()
  @type message() :: Mud.Engine.Input.t() | Mud.Engine.Output.t()
  @type messages() :: [message()]
  @type success() :: boolean()
  @type terminate_session() :: boolean()
  @type context() :: __MODULE__.t()

  @enforce_keys [:id, :character_id, :input]
  defstruct [
    # The ID of the input which triggered this execution of the verb logic
    :id,
    # The populated Command struct
    :command,
    # ID for the Character that the command is being processed for.
    :character_id,
    # The Character that the command is being processed for. Will be populated immediatly before execution, in the
    # transaction.
    :character,
    # Generic data container for commands
    {:data, %{}},
    # Messages to be sent upon successful execution of logic.
    {:messages, []},
    # The raw text input before any processing.
    :input,
    # Whether or not the execution was successful. Will be nil if execution has not been performed.
    :success,
    # If success is false, the message will be populated with the reason why.
    :error_message,
    # A special flag that can be returned by any command which signals the character session to close.
    {:terminate_session, false},
    # The command that was processed the first time around.
    {:continuation_command, nil},
    # Data which is preserved between the initial/continuing calls of a single command. Can be used to carry
    # information over such as the objects that are being selected from. For example, if the 'look' command returns a
    # list of 5 items, the exact item to be looked at should be preserved between commands so that if the player enters
    # '1' the command can be applied correctly.
    {:continuation_data, %{}},
    # Flag whether or not this is a continuation of a previous command execution.
    {:is_continuation, false},
    # The callback module to call on continuation.
    :continuation_module,
    # The type of continuiation it is, such as numeric. Meaning a number being entered continues while anything else is
    # executed as is instead while the continuation data is dropped.
    :continuation_type
  ]

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
  @spec set_success(context, boolean) :: context
  def set_success(%__MODULE__{} = context, successful \\ true) when is_boolean(successful) do
    %{context | success: successful}
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
    %{context | continuation_data: nil}
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
      | continuation_data: nil,
        continuation_module: nil,
        continuation_type: nil,
        is_continuation: false
    }
  end

  @doc """
  Mark an execution process as successful, while adding a message to it in the process.
  """
  @spec success_with_output(
          context,
          String.t(),
          String.t()
        ) :: context
  def success_with_output(context, message, tag) do
    context
    |> Mud.Engine.Command.ExecutionContext.append_message(
      Mud.Engine.Util.output(
        context.character_id,
        "{{#{tag}}}#{message}{{/#{tag}}}"
      )
    )
    |> set_success()
  end
end
