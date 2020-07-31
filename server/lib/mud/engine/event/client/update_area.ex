defmodule Mud.Engine.Event.Client.UpdateArea do
  use TypedStruct

  typedstruct do
    # add, remove, update
    field(:action, String.t(), required: true)
    # the item being updated
    field(:things, struct(), required: true)
  end

  def new(action, things) do
    %__MODULE__{
      action: action,
      things: List.wrap(things)
    }
  end
end
