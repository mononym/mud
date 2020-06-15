defmodule MudWeb.Live.Component.CharacterInventory do
  use Phoenix.LiveComponent

  alias Mud.Engine.Item

  def mount(socket) do
    socket =
      socket
      |> assign(
        :containers_expanded,
        true
      )

    {:ok, socket}
  end

  # def update(assigns, socket) do
  #   IO.inspect(assigns)

  #   items =
  #     Item.list_all_recursive(assigns.inventory.worn_containers)
  #     |> Enum.reduce(%{}, fn item, map ->
  #       Map.put(map, item.id, item)
  #     end)

  #   socket =
  #     socket
  #     |> assign(
  #       :worn_containers,
  #       assigns.inventory.worn_containers
  #     )
  #     |> assign(
  #       :all_items_index,
  #       items
  #     )

  #   {:ok, socket}
  # end

  def render(assigns) do
    Phoenix.View.render(MudWeb.MudClientView, "character_inventory.html", assigns)
  end

  def handle_event("toggle_containers", _, socket) do
    {:noreply,
     assign(
       socket,
       :containers_expanded,
       not socket.assigns.containers_expanded
     )}
  end

  def handle_event("toggle_container", _, socket) do
    id = ""

    {:noreply,
     assign(
       socket,
       :containers_expanded,
       not socket.assigns.containers_expanded
     )}
  end
end
