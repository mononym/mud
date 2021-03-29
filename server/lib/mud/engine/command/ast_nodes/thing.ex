defmodule Mud.Engine.Command.AstNode.Thing do
  use TypedStruct

  typedstruct do
    field(:input, String.t(), default: nil)
    field(:personal, boolean(), default: false)
    field(:switch, String.t(), default: nil)
    field(:where, String.t(), default: nil)
    field(:which, integer(), default: 0)
  end
end
