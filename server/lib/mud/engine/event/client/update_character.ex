defmodule Mud.Engine.Event.Client.UpdateCharacter do
  use TypedStruct

  typedstruct do
    # add, remove, update
    field(:action, String.t(), default: "character")
    # the item being updated
    field(:character, Mud.Engine.Character.t())
    # the wealth being updated on a character
    field(:wealth, Mud.Engine.Character.Wealth.t())
  end

  def new(action, character) do
    %__MODULE__{
      action: action,
      character: character
    }
  end

  def new(params) do
    struct(__MODULE__, params)
  end
end
