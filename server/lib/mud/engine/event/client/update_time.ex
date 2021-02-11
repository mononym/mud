defmodule Mud.Engine.Event.Client.UpdateTime do
  use TypedStruct

  @derive {Jason.Encoder,
           only: [
             :action,
             :hour,
             :time_string
           ]}
  typedstruct do
    # update
    field(:action, String.t(), required: false, default: :update)
    # The hour of the day
    field(:hour, :float, required: true)
    # The string description of the time of day
    field(:time_string, :string, required: true)
  end

  def new(params) do
    struct(__MODULE__, params)
  end
end
