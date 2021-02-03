defmodule Mud.Engine.Event.Client.UpdateInventory do
  use TypedStruct

  typedstruct do
    # add, remove, update
    field(:action, String.t(), required: true)
    # the item being updated
    field(:items, struct(), required: true)
  end

  def new(action, items) do
    %__MODULE__{
      action: action,
      items: List.wrap(items)
    }
  end

  def new(params) do
    struct!(__MODULE__, params)
  end
end
