defmodule Mud.Engine.Command.AstNode.Thing do
  use TypedStruct

  typedstruct do
    field(:which, integer(), default: 0)
    field(:personal, boolean(), default: false)
    field(:input, String.t(), default: nil)
    field(:where, String.t(), default: nil)
  end
end
