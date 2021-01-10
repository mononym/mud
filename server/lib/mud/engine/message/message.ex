defmodule Mud.Engine.Message do
  @moduledoc """
  Helper methods for dealing with Input/Output messages.
  """

  alias Mud.Engine.Mode.Character
  alias Mud.Engine.Message.Output
  alias Mud.Engine.Message.TextOutput
  alias Mud.Engine.Message.TextOutput.Segment
  alias Mud.Engine.Message.Input

  @type message() :: String.t()
  @type tag() :: String.t()
  @type to() :: String.t() | [String.t()] | Character.t() | [Character.t()]

  #
  #
  # Text Output API
  #
  #

  @doc """
  Create a new Text Output message for one or more characters given their id's.

  Text outputs are built up incrementally, allowing for the tagging of arbitrary lengths of text as belonging to a
  'type' which is then used on the client side to perform real-time color for the text.
  """
  def new_text_output(to) do
    to
    |> maybe_transform_to()
    |> text_output()
  end

  @spec append_text(Mud.Engine.Message.TextOutput.t(), String.t(), String.t()) ::
          Mud.Engine.Message.TextOutput.t()
  def append_text(output = %TextOutput{}, text, type) do
    %{output | segments: [%Segment{text: text, type: type} | output.segments]}
  end

  @spec drop_last_text(Mud.Engine.Message.TextOutput.t()) ::
          Mud.Engine.Message.TextOutput.t()
  def drop_last_text(output = %TextOutput{}) do
    IO.inspect(output)
    IO.inspect(%{output | segments: output.segments |> Enum.reverse() |> tl() |> Enum.reverse()})
    %{output | segments: tl(output.segments)}
  end

  def new_input(to, message, type) do
    to
    |> List.wrap()
    |> maybe_transform_to()
    |> input(message, type)
  end

  def new_output(to, message) do
    to
    |> maybe_transform_to()
    |> output(message)
  end

  def new_output(to, message, tag) when is_binary(tag) do
    msg = maybe_tag_message(message, tag)

    to
    |> maybe_transform_to()
    |> output(msg)
  end

  def new_output(to, message, table_data) when is_list(table_data) do
    to
    |> maybe_transform_to()
    |> output(message, table_data)
  end

  def new_output(to, message, tag, table_data) when is_binary(tag) and is_list(table_data) do
    msg = maybe_tag_message(message, tag)

    to
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
    to
    |> List.wrap()
    |> Enum.map(fn dest ->
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

  defp text_output(to) do
    %TextOutput{
      id: UUID.uuid4(),
      to: to
    }
  end
end
