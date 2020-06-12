defmodule Mud.Engine.Command.AstNode.CommandInput do
  use TypedStruct

  alias Mud.Engine.Command.AstNode

  typedstruct do
    field(:command, String.t())
    field(:input, String.t())
  end
end
