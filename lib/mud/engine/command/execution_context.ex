defmodule Mud.Engine.Command.ExecutionContext do
  @moduledoc """
  A CommandContext struct contains everything required for the processing of a Command.
  The context is intended to be passed between multiple middlewares, some of which may need to run before others to
  populate required data.
  """

  @enforce_keys [:id, :character_id, :raw_input]
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
    # Messages to be sent upon successful execution of logic.
    {:messages, []},
    # The raw text input before any processing.
    :raw_input,
    # Whether or not the execution was successful. Will be nil if execution has not been performed.
    :success,
    # If success is false, the message will be populated with the reason why.
    :error_message,
    # A special flag that can be returned by any command which signals the character session to close.
    {:terminate_session, false},
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
  @spec append_message(%__MODULE__{}, struct) :: %__MODULE__{}
  def append_message(%__MODULE__{} = context, message) do
    %{context | messages: [message | context.messages]}
  end

  @doc """
  Append a message to the list of messages which will be sent after the command has been executed
  """
  @spec set_success(%__MODULE__{}, boolean) :: %__MODULE__{}
  def set_success(%__MODULE__{} = context, successful \\ true) when is_boolean(successful) do
    %{context | success: successful}
  end

  @doc """
  Set the flag that signals the session to close after post processing has finished.
  """
  @spec terminate_session(%__MODULE__{}, boolean) :: %__MODULE__{}
  def terminate_session(%__MODULE__{} = context, terminate \\ true) when is_boolean(terminate) do
    %{context | terminate_session: terminate}
  end

  @doc """
  Delete a value from the data embedded in the Context.
  """
  def clear_continuation_data(%__MODULE__{} = context) do
    %{context | continuation_data: nil}
  end

  @doc """
  Get a value from the data embedded in the Context.
  """
  def get_continuation_data(%__MODULE__{} = context, key) do
    Map.get(context.data, key)
  end

  @doc """
  Put a value into the data embedded in the Context, returning the updated Context.
  """
  def set_continuation_data(%__MODULE__{} = context, data) do
    %{context | continuation_data: data}
  end

  @doc """
  Flag whether or not this context is for a continuiation
  """
  def set_is_continuation(context, value \\ false) do
    %{context | is_continuation: value}
  end

  @doc """
  Put a value into the data embedded in the Context, returning the updated Context.
  """
  def set_continuation_module(%__MODULE__{} = context, module) do
    %{context | continuation_module: module}
  end

  @doc """
  Put a value into the data embedded in the Context, returning the updated Context.
  """
  def set_continuation_type(%__MODULE__{} = context, type) do
    %{context | continuation_type: type}
  end

  @doc """
  Put a value into the data embedded in the Context, returning the updated Context.
  """
  def clear_continuation_module(%__MODULE__{} = context) do
    %{context | continuation_module: nil}
  end
end
