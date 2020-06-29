defmodule MudWeb.ClientData do
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
      # Held tems
      field(:held_items, [Item.t()])

      # Item held in right hand
      field(:worn_containers, [Item.t()], default: [])

      # Map where the key is an item id and the value is a list of items which are children of that item
      field(:item_child_index, map(), default: %{})

      # Map where the key is an item id and the value is the item
      field(:item_index, map(), default: %{})
    end
  end

  defmodule AreaOverview do
    use TypedStruct

    @derive Jason.Encoder
    typedstruct do
      field(:area, Mud.Engine.Area.t())

      field(:exits, map(), default: %{})

      field(:characters, map(), default: %{})

      field(:things_of_interest, map(), default: %{})

      field(:items, map(), default: %{})

      # Map where the key is an item id and the value is a list of items which are children of that item
      field(:item_child_index, map(), default: %{})
    end
  end
end
