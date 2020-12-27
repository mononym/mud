defmodule Mud.Engine.Message.TextOutput do
  use TypedStruct

  @derive Jason.Encoder
  typedstruct do
    field(:id, String.t(), required: true)
    field(:segments, [Segment.t()], required: false, default: [])
    field(:to, [String.t()], required: true)
  end

  defmodule Segment do
    use TypedStruct

    @derive Jason.Encoder
    typedstruct do
      field(:text, String.t(), required: true)
      field(:type, String.t(), required: false, default: "text")
    end
  end
end
