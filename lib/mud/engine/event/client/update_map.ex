defmodule Mud.Engine.Event.Client.UpdateMap do
  use TypedStruct

  @derive {Jason.Encoder,
           only: [
             :action,
             :areas,
             :links,
             :explored_areas,
             :map_id
           ]}
  typedstruct do
    # add, remove, update
    field(:action, String.t(), required: false, default: :move)
    # areas the character knows about
    field(:areas, [struct()], required: false, default: [])
    # links the character knows about
    field(:links, [struct()], required: false, default: [])
    # links the character knows about
    field(:explored_areas, [String.t()], required: false, default: [])
    # maps that are now explored
    field(:maps, [struct()], required: false, default: [])
    # the id of the map being updated
    field(:map_id, String.t(), required: true)
    # the id of the area the player is in
    field(:area_id, String.t(), required: false, default: "")
  end

  def new(params) do
    struct(__MODULE__, params)
  end
end
