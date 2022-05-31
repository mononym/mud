defmodule Mud.Engine.Event.Client.CloseSession do
  use TypedStruct

  typedstruct do
    # quit
    field(:action, String.t(), required: false, default: :quit)
  end

  def new(params \\ %{}) do
    struct(__MODULE__, params)
  end
end
