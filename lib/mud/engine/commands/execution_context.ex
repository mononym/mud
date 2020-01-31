defmodule Mud.Engine.Command.ExecutionContext do
  @moduledoc """
  An ExecutionContext struct contains everything required for the processing of a Command.
  The context is intended to be passed between multiple middlewares, some of which may need to run before others to
  populate required data.
  """

  @enforce_keys [:character_id, :player_id, :raw_input]
  defstruct [
    # Parsed arguments for the command.
    :args,
    # The callback module that will execute the actual logic.
    :callback_module,
    # Character that the command is being processed for.
    :character_id,
    # Character that the command is being processed for.
    :player_id,
    # The raw verb which was split off from the input. So, for the input 'mo east' the raw_verb would be 'mo'
    :raw_verb,
    # The verb which was actually matched. So, for the input 'mo east' the matched_verb would be 'move'
    :matched_verb,
    # Messages to be sent upon successful execution of logic.
    {:messages, []},
    # The raw text input before any processing.
    :raw_input,
    # The raw argument string, which is the raw_input minus the matched command.
    :raw_args,
    # Data container to facilitate middleware communication.
    {:data, %{}},
    # Whether or not the execution was successful. Will be nil if execution has not been performed.
    :success,
    # If success is false, the message will be populated with the reason why.
    :error_message
  ]

  @type t :: %Mud.Engine.Command.ExecutionContext{
          args: term,
          character_id: String.t(),
          player_id: String.t(),
          raw_verb: String.t(),
          matched_verb: String.t(),
          messages: [Mud.Engine.OutputMessage.t()],
          raw_input: String.t(),
          raw_args: String.t(),
          data: map,
          success: boolean,
          error_message: term
        }

  @doc """
  Append a message to the list of messages which will be sent after the command has been executed
  """
  @spec append_message(%__MODULE__{}, struct) :: %__MODULE__{}
  def append_message(%__MODULE__{} = context, message) do
    %{context | messages: context.messages ++ [message]}
  end

  @doc """
  Append a message to the list of messages which will be sent after the command has been executed
  """
  @spec set_success(%__MODULE__{}, boolean) :: %__MODULE__{}
  def set_success(%__MODULE__{} = context, successful) when is_boolean(successful) do
    %{context | success: successful}
  end

  @doc """
  Delete a value from the data embedded in the Context.
  """
  @spec delete(%__MODULE__{}, String.t() | atom()) :: %__MODULE__{}
  def delete(%__MODULE__{} = context, key) do
    %{context | data: Map.delete(context.data, key)}
  end

  @doc """
  Get a value from the data embedded in the Context.
  """
  @spec get(%__MODULE__{}, String.t() | atom()) :: any()
  def get(%__MODULE__{} = context, key) do
    Map.get(context.data, key)
  end

  @doc """
  Check to see if a key exists in the data of the Context.
  """
  @spec has_key?(%__MODULE__{}, String.t() | atom()) :: boolean()
  def has_key?(%__MODULE__{} = context, key) do
    Map.has_key?(context.data, key)
  end

  @doc """
  Put a value into the data embedded in the Context, returning the updated Context.
  """
  @spec put(%__MODULE__{}, String.t() | atom(), term()) :: %__MODULE__{}
  def put(%__MODULE__{} = context, key, value) do
    %{context | data: Map.put(context.data, key, value)}
  end
end

defimpl String.Chars, for: Mud.Engine.Command.ExecutionContext do
  def to_string(%Mud.Engine.Command.ExecutionContext{} = execution) do
    "%{character: '#{execution.character}', matched_verb:'#{execution.matched_verb}'," <>
      " player: '#{execution.player}', raw_input: '#{execution.raw_input}'}"
  end
end