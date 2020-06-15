defmodule Mud.Engine.ClientData do
  @moduledoc """
  The definition for the data required by the client. Will not include things like main window or the actual chat
  messages in chat windows.
  """
  use TypedStruct

  @derive Jason.Encoder
  typedstruct do
    # The inventory window
    field(:inventory, String.t(), required: true)
  end

  defmodule Inventory do
    use TypedStruct

    @derive Jason.Encoder
    typedstruct do
      # Item held in left hand
      field(:left_hand, Item.t())

      # Item held in right hand
      field(:right_hand, Item.t())

      # Item held in right hand
      field(:worn_containers, [Item.t()], default: [])
      field(:item_child_index, map(), default: %{})
    end

    defmodule Item do
      use TypedStruct

      @derive Jason.Encoder
      typedstruct do
        field(:id, String.t(), required: true)
        field(:text, String.t(), required: true)
        field(:parent, String.t(), required: true)
        field(:icon, String.t(), default: "fas fa-question")
        field(:opened, boolean, default: false)
        field(:disabled, boolean, default: false)
        field(:selected, boolean, default: false)
        field(:selectable, boolean, default: true)
      end
    end
  end
end
