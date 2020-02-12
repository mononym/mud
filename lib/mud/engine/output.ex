defmodule Mud.Engine.Output do
  defstruct id: nil, text: nil, character_id: nil, table_data: nil

  def transform_for_web(output = %__MODULE__{table_data: table_data, text: message})
      when not is_nil(table_data) do
    list_items = Enum.join(table_data, "</li>{{/info}}{{info}}<li>")

    text =
      "<ol class=\"list-decimal list-inside\" start=\"0\">{{info}}<li>" <>
        list_items <> "</li></ol>{{/info}}"

    case message do
      nil ->
        transform_for_web(%{output | table_data: nil, text: text})

      msg ->
        transform_for_web(%{output | table_data: nil, text: msg <> text})
    end
  end

  def transform_for_web(%__MODULE__{table_data: nil, text: text}) do
    Mud.Text.from_tagged_to_html(text)
  end

  def transform_for_web(text) when is_binary(text) do
    Mud.Text.from_tagged_to_html(text)
  end
end
