defmodule Mud.Engine.Event.Client.UpdateCharacter do
  use TypedStruct

  typedstruct do
    # add, remove, update
    field(:action, String.t(), required: true, default: :update)
    # the item being updated
    field(:character, Mud.Engine.Character.t(), required: true)
  end

  def new(action \\ :update, character) do
    %__MODULE__{
      action: action,
      character: character
    }
  end
end
