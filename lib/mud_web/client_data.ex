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
    end

    defmodule Item do
      use TypedStruct

      @derive Jason.Encoder
      typedstruct do
        # uniquely id each item
        field(:id, String.t(), required: true)
        # used for the tree view
        field(:short_description, String.t(), required: true)
        # used for the detail view
        field(:long_description, String.t(), required: true)
        # if this item is inside another item it will have an id
        field(:parent, String.t())
        # for use in drawing the tree view
        field(:children, [], default: [])
        # the icon to use for the item in the row
        field(:icon, String.t(), default: "fas fa-question")
        # if the item can be opened or not
        field(:openable, boolean, default: false)
        # if the item is open or not
        field(:opened, boolean, default: false)
        # if the item should be disabled or not in the UI
        field(:disabled, boolean, default: false)
        # If the item has been selected
        field(:selected, boolean, default: false)
        # The actions which can be taken on the item.
        # For example an entry of %{text: "Open", command: "open my #{item.id}"}
        # would create an "Open" button when the item is selected, which when clicked would silently send that
        # command to the server
        field(:actions, [], default: [])
      end
    end
  end
end
