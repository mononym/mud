defmodule Mud.Engine.Event.Client.UpdateArea do
  use TypedStruct

  @derive {Jason.Encoder,
           only: [
             :action,
             :area,
             :other_characters,
             :items,
             :denizens,
             :exits
           ]}
  typedstruct do
    # add, remove, update
    field(:action, String.t(), required: false, default: :look)
    # the item being updated
    field(:area, [struct()], required: true)
    # Other characters in the area
    field(:other_characters, [struct()], required: false, default: [])
    # Items on the ground
    field(:items, [struct()], required: false, default: [])
    # Denizens in the area
    field(:denizens, [struct()], required: false, default: [])
    # Exits leading from the area
    field(:exits, [struct()], required: false, default: [])
  end

  def new(params) do
    struct(__MODULE__, params)
  end
end
