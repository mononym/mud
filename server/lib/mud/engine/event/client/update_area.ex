defmodule Mud.Engine.Event.Client.UpdateArea do
  use TypedStruct

  @derive {Jason.Encoder,
           only: [
             :action,
             :area,
             :other_characters,
             :on_ground,
             :denizens
           ]}
  typedstruct do
    # add, remove, update
    field(:action, String.t(), required: false, default: :replace)
    # the item being updated
    field(:area, [struct()], required: true)
    # Other characters in the area
    field(:other_characters, [struct()], required: false, default: [])
    # Items on the ground
    field(:on_ground, [struct()], required: false, default: [])
    # Items on the ground
    field(:denizens, [struct()], required: false, default: [])
  end

  def new(params) do
    struct(__MODULE__, params)
  end
end
