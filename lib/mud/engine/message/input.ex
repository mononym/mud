defmodule Mud.Engine.Message.Input do
  use TypedStruct

  typedstruct do
    # How the segment will be uniquely known in the AST
    field(:id, String.t(), required: true)
    field(:text, String.t(), required: true)
    field(:to, [String.t()], required: true)
    field(:player_id, String.t(), required: true)
    field(:type, :normal | :silent, default: :normal)
  end
end
