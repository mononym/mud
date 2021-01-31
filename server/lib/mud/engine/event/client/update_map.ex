defmodule Mud.Engine.Event.Client.UpdateMap do
  use TypedStruct

  @derive {Jason.Encoder,
           only: [
             :action,
             :area,
             :links,
             :explored
           ]}
  typedstruct do
    # add, remove, update
    field(:action, String.t(), required: false, default: :move)
    # areas the character knows about
    field(:areas, [struct()], required: true)
    # links the character knows about
    field(:links, [struct()], required: false, default: [])
    # links the character knows about
    field(:explored, [String.t()], required: false, default: [])
  end

  def new(params) do
    struct(__MODULE__, params)
  end
end
