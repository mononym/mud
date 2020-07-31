defmodule Mud.Engine.Command.AstNode.Place do
  use TypedStruct

  typedstruct do
    field(:which, integer(), default: 0)
    field(:personal, boolean(), default: false)
    field(:input, String.t(), required: true)
    field(:where, String.t())
    field(:path, %Mud.Engine.Command.AstNode.Place{})
  end
end
