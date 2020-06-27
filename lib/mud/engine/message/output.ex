defmodule Mud.Engine.Message.Output do
  use TypedStruct

  typedstruct do
    field(:id, String.t(), required: true)
    field(:text, String.t(), required: true)
    field(:to, [String.t()], required: true)
    field(:table_data, [String.t()], default: nil)
  end

  def transform_for_web(output = %__MODULE__{table_data: table_data, text: message})
      when not is_nil(table_data) do
    list_items = Enum.join(table_data, "</li>{{/info}}{{info}}<li>")

    text =
      "<ol id=\"#{output.id}-table\" class=\"list-decimal list-inside\" start=\"1\">{{info}}<li>" <>
        list_items <> "</li></ol>{{/info}}"

    case message do
      nil ->
        transform_for_web(%{output | table_data: nil, text: text})

      msg ->
        transform_for_web(%{output | table_data: nil, text: msg <> text})
    end
  end

  def transform_for_web(output = %__MODULE__{table_data: nil, text: text}) do
    text = Mud.Text.from_tagged_to_html(text)

    "<p id=\"#{output.id}\" class=\"whitespace-pre-wrap\">" <> text <> "</p>"
  end

  def transform_for_web(text) when is_binary(text) do
    Mud.Text.from_tagged_to_html(text)
  end
end
