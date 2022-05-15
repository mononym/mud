defmodule Mud.Engine.Message.Output do
  use TypedStruct

  typedstruct do
    field(:id, String.t(), required: true)
    field(:text, String.t(), required: true)
    field(:to, [String.t()], required: true)
    field(:type, String.t(), required: false, default: "system warning")
    field(:table_data, [String.t()], default: nil)
  end
end
