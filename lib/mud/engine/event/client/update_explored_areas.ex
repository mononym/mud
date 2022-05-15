defmodule Mud.Engine.Event.Client.UpdateExploredArea do
  use TypedStruct

  @derive {Jason.Encoder,
           only: [
             :action,
             :areas
           ]}
  typedstruct do
    # add, remove, update
    field(:action, String.t(), required: false, default: :look)
    # the areas to be added to the map data, generally unexplored areas linked to the area the character just moved
    # to
    field(:areas, [struct()], required: false, default: [])
    # the links to be added to the map data, generally the connections to unexplored areas from the area the character
    # just moved to
    field(:links, [struct()], required: false, default: [])
    # the strings of the newly explored area ids
    field(:explored, [String.t()], required: true)
  end

  def new(params) do
    struct(__MODULE__, params)
  end
end
