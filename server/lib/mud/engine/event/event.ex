defmodule Mud.Engine.Event do
  use TypedStruct

  typedstruct do
    field(:id, String.t(), required: true)
    field(:to, [String.t()], required: true)
    field(:event, struct(), required: true)
  end

  @spec new(to :: String.t() | [String.t()], event :: struct()) :: Mud.Engine.Event.t()
  def new(to, event) do
    to =
      to
      |> List.wrap()
      |> Enum.map(fn dest ->
        if is_struct(dest) do
          dest.id
        else
          dest
        end
      end)

    %__MODULE__{
      id: UUID.uuid4(),
      to: to,
      event: event
    }
  end
end
