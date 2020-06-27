defmodule Mud.Engine.Event.Client.UpdateInventory do
  use TypedStruct

  typedstruct do
    # add, remove, update
    field(:action, String.t(), required: true)
    # the item being updated
    field(:item, String.t(), required: true)
  end
end
