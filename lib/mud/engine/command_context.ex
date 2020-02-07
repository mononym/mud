defmodule Mud.Engine.CommandContext do
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
    # Parsed arguments for the command.
    :parsed_args,
    # ID for the Character that the command is being processed for.
    :character_id,
    # The Character that the command is being processed for. Will be populated immediatly before execution, in the
    # transaction.
    :character,
    # Messages to be sent upon successful execution of logic.
    {:messages, []},
    # The raw text input before any processing.
    :raw_input,
    # The raw argument string, which is the raw_input minus the verb.
    :raw_argument_string,
    # Whether or not the execution was successful. Will be nil if execution has not been performed.
    :success,
    # If success is false, the message will be populated with the reason why.
    :error_message,
    # A special flag that can be returned by any command which signals the character session to close.
    {:terminate_session, false}
  ]

  @doc """
  Process the execution context by running it through the middleware list it contains. Spooky.
  """
  def process(%__MODULE__{} = context) do
    Enum.reduce(context.middleware, context, fn middleware_callback, cxt ->
      middleware_callback.execute(cxt)
    end)
  end

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
  def set_success(%__MODULE__{} = context, successful) when is_boolean(successful) do
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
  def delete(%__MODULE__{} = context, key) do
    %{context | data: Map.delete(context.data, key)}
  end

  @doc """
  Get a value from the data embedded in the Context.
  """
  def get(%__MODULE__{} = context, key) do
    Map.get(context.data, key)
  end

  @doc """
  Check to see if a key exists in the data of the Context.
  """
  def has_key?(%__MODULE__{} = context, key) do
    Map.has_key?(context.data, key)
  end

  @doc """
  Put a value into the data embedded in the Context, returning the updated Context.
  """
  def put(%__MODULE__{} = context, key, value) do
    %{context | data: Map.put(context.data, key, value)}
  end
end
