defmodule Mud.Engine.Command.AstNode.OneThing do
  use TypedStruct

  alias Mud.Engine.Command.AstNode

  typedstruct do
    field(:command, String.t())
    field(:thing, %AstNode.Thing{})
  end
end
