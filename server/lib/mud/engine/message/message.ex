defmodule Mud.Engine.Message do
  @moduledoc """
  Helper methods for dealing with Input/Output messages.
  """

  alias Mud.Engine.Mode.Character
  alias Mud.Engine.Message.Output
  alias Mud.Engine.Message.StoryOutput
  alias Mud.Engine.Message.StoryOutput.Segment
  alias Mud.Engine.Message.Input

  @type message() :: String.t()
  @type tag() :: String.t()
  @type to() :: String.t() | [String.t()] | Character.t() | [Character.t()]

  #
  #
  # Text Output API
  #
  #

  @spec new_story_output(list) :: Mud.Engine.Message.StoryOutput.t()
  @doc """
  Create a new Text Output message for one or more characters given their id's.

  Text outputs are built up incrementally, allowing for the tagging of arbitrary lengths of text as belonging to a
  'type' which is then used on the client side to perform real-time color for the text.
  """
  def new_story_output(to) do
    to
    |> maybe_transform_to()
    |> story_output()
  end

  @doc """
  Create a new Text Output message for one or more characters given their id's with a given message and type.

  Text outputs are built up incrementally, allowing for the tagging of arbitrary lengths of text as belonging to a
  'type' which is then used on the client side to perform real-time color for the text.
  """
  def new_story_output(to, text, type) do
    to
    |> maybe_transform_to()
    |> story_output()
    |> append_text(text, type)
  end

  @spec append_text(Mud.Engine.Message.StoryOutput.t(), String.t(), String.t()) ::
          Mud.Engine.Message.StoryOutput.t()
  def append_text(output = %StoryOutput{}, text, type) do
    %{output | segments: [%Segment{text: text, type: type} | output.segments]}
  end

  @spec drop_last_text(Mud.Engine.Message.StoryOutput.t()) ::
          Mud.Engine.Message.StoryOutput.t()
  def replace_second_to_last_text(output = %StoryOutput{}, text, type) do
    # Only do the replacement if there are 3 or more entries
    if length(output.segments) > 2 do
      %{
        output
        | segments:
            List.insert_at(output.segments, length(output.segments) - 2, %Segment{
              text: text,
              type: type
            })
      }
    else
      output
    end
  end

  @spec drop_last_text(Mud.Engine.Message.StoryOutput.t()) ::
          Mud.Engine.Message.StoryOutput.t()
  def drop_last_text(output = %StoryOutput{}) do
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

  defp story_output(to) do
    %StoryOutput{
      id: UUID.uuid4(),
      to: to
    }
  end
end
