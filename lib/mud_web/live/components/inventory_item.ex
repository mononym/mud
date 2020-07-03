defmodule MudWeb.Live.Component.InventoryItem do
  use Phoenix.LiveComponent

  alias Mud.Engine.Character
  alias Mud.Engine.Item

  def mount(socket) do
    {:ok,
     assign(socket,
       expanded: false
     )}
  end

  def preload(assigns) do
    Enum.map(assigns, fn assign ->
      assign
      |> Map.put(:item, assign.item_index[assign.id])
      |> Map.put(:children, assign.child_index[assign.id])
    end)
  end

  def render(assigns) do
    Phoenix.View.render(MudWeb.MudClientView, "inventory_item.html", assigns)
  end

  def handle_event("toggle_container", _, socket) do
    {:noreply,
     assign(socket,
       item: Item.toggle_container_open(socket.assigns.item.id)
     )}
  end

  def handle_event("toggle_expanded", _, socket) do
    {:noreply,
     assign(socket,
       expanded: not socket.assigns.expanded
     )}
  end
end
