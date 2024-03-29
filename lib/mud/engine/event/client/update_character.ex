defmodule Mud.Engine.Event.Client.UpdateCharacter do
  use TypedStruct

  typedstruct do
    # add, remove, update
    field(:action, String.t(), default: "character")
    # the item being updated
    field(:character, Mud.Engine.Character.t())
    # the containers settings being updated on a character
    field(:containers, Mud.Engine.Character.Containers.t())
    # the wealth being updated on a character
    field(:wealth, Mud.Engine.Character.Wealth.t())
    # the bank being updated on a character
    field(:bank, Mud.Engine.Character.Bank.t())
    # the status being updated on a character
    field(:status, Mud.Engine.Character.Status.t())
    # the settings being updated on a character
    field(:settings, Mud.Engine.Character.Settings.t())
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
