defmodule Mud.Engine.Message do
  @moduledoc """
  Helper methods for dealing with Input/Output messages.
  """

  alias Mud.Engine.Mode.Character
  alias Mud.Engine.Message.Output
  alias Mud.Engine.Message.Input

  @type message() :: String.t()
  @type tag() :: String.t()
  @type to() :: String.t() | [String.t()] | Character.t() | [Character.t()]

  def new_input(to, message, type) do
    to
    |> List.wrap()
    |> maybe_transform_to()
    |> input(message, type)
  end

  def new_output(to, message) do
    to
    |> List.wrap()
    |> maybe_transform_to()
    |> output(message)
  end

  def new_output(to, message, tag) when is_binary(tag) do
    msg = maybe_tag_message(message, tag)

    to
    |> List.wrap()
    |> maybe_transform_to()
    |> output(msg)
  end

  def new_output(to, message, table_data) when is_list(table_data) do
    to
    |> List.wrap()
    |> maybe_transform_to()
    |> output(message, table_data)
  end

  def new_output(to, message, tag, table_data) when is_binary(tag) and is_list(table_data) do
    msg = maybe_tag_message(message, tag)

    to
    |> List.wrap()
    |> maybe_transform_to()
    |> output(msg, table_data)
  end

  @spec maybe_tag_message(message(), tag()) :: message()
  defp maybe_tag_message(message, tag) do
    if tag != nil do
      "{{#{tag}}}#{message}{{/#{tag}}}"
    else
      message
    end
  end

  @spec maybe_transform_to([String.t()] | [Character.t()]) :: [String.t()]
  defp maybe_transform_to(to) do
    Enum.map(to, fn dest ->
      if is_map(dest) do
        dest.id
      else
        dest
      end
    end)
  end

  defp input(to, message, type) do
    %Input{
      id: UUID.uuid4(),
      to: to,
      text: message,
      type: type
    }
  end

  defp output(to, message, table_data \\ nil) do
    %Output{
      id: UUID.uuid4(),
      to: to,
      text: message,
      table_data: table_data
    }
  end
end
