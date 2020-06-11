defmodule Mud.Engine.Command.AstNode.ThingAndPlace do
  use TypedStruct

  alias Mud.Engine.Command.AstNode

  typedstruct do
    field(:command, String.t())
    field(:thing, %AstNode.Thing{})
    field(:place, %AstNode.Place{})
  end
end
