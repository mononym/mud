defmodule Mud.Engine.Event.Client.UpdateShops do
  use TypedStruct

  @derive {Jason.Encoder,
           only: [
             :action,
             :shops
           ]}
  typedstruct do
    # update
    field(:action, String.t(), required: false, default: :add)
    # The hour of the day
    field(:shops, {:array, Mud.Engine.Shop.t()}, required: true)
  end

  def new(params) do
    struct(__MODULE__, params)
  end
end
