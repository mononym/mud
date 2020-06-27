defmodule Mud.Engine.Command.AstNode.CommandInput do
  use TypedStruct

  typedstruct do
    field(:command, String.t())
    field(:input, String.t())
  end
end
