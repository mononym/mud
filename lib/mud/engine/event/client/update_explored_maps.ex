defmodule Mud.Engine.Event.Client.UpdateExploredMap do
  use TypedStruct

  @derive {Jason.Encoder,
           only: [
             :action,
             :maps
           ]}
  typedstruct do
    # add, remove, update
    field(:action, String.t(), required: false, default: :look)
    field(:maps, [struct()], required: true)
  end

  def new(params) do
    struct(__MODULE__, params)
  end
end
