defmodule MudWeb.Live.Component.CharacterInventory do
  use Phoenix.LiveComponent

  alias Mud.Engine
  alias Mud.Engine.Character
  alias MudWeb.ClientData.Inventory
  require Logger

  def mount(socket) do
    socket =
      socket
      |> assign(
        containers_expanded: true,
        held_expanded: true,
        loading: true,
        event: nil,
        initialized: false
      )

    {:ok, socket, temporary_assigns: [event: nil]}
  end

  def preload(assigns_list) do
    Enum.map(assigns_list, fn assigns ->
      if Map.has_key?(assigns, :id) do
        assigns
        |> Map.put(:inventory_data, init_inventory_data(assigns.id))
        |> Map.put(:loading, false)
      else
        if Map.has_key?(assigns, :event) do
          inventory = assigns.inventory_data
          event = assigns.event
          items = event.items

          updated_index =
            case event.action do
              :add ->
                Enum.reduce(items, inventory.item_index, fn item, index ->
                  Map.put(index, item.id, item)
                end)

              :remove ->
                Enum.reduce(items, inventory.item_index, fn item, index ->
                  if item.updated_at > index[item.id].updated_at do
                    Map.delete(index, item.id)
                  else
                    index
                  end
                end)

              :update ->
                Enum.reduce(items, inventory.item_index, fn item, index ->
                  if item.updated_at > index[item.id].updated_at do
                    Map.put(index, item.id, item)
                  else
                    index
                  end
                end)
            end

          inv =
            inventory
            |> Map.put(:item_index, updated_index)
            |> generate_child_index()

          Map.put(assigns, :inventory_data, inv)
        else
          assigns
        end
      end
    end)
  end

  def render(assigns) do
    Phoenix.View.render(MudWeb.MudClientView, "character_inventory.html", assigns)
  end

  def handle_event("toggle_held", _, socket) do
    {:noreply,
     assign(
       socket,
       :held_expanded,
       not socket.assigns.held_expanded
     )}
  end

  def handle_event("toggle_containers", _, socket) do
    {:noreply,
     assign(
       socket,
       :containers_expanded,
       not socket.assigns.containers_expanded
     )}
  end

  defp init_inventory_data(character_id) do
    inv =
      %Inventory{}
      |> populate_held_items(character_id)
      |> populate_worn_items(character_id)

    Logger.debug(inspect(inv))
    root_items = inv.held_items ++ inv.worn_containers

    Logger.debug(inspect(root_items))

    all_items = Engine.Item.list_all_recursive(root_items)
    item_index = Map.new(all_items, &{&1.id, &1})

    inv
    |> Map.put(:item_index, item_index)
    |> generate_child_index()
  end

  defp generate_child_index(inventory) do
    all_items = Map.values(inventory.item_index)

    item_child_index =
      Enum.reduce(all_items, %{}, fn item, map ->
        value = [item.id | Map.get(map, item.container_id, [])]
        Map.put(map, item.container_id, value)
      end)

    Map.put(inventory, :item_child_index, item_child_index)
  end

  defp populate_held_items(inventory, character_id) do
    held_items = Character.list_held_items(character_id)

    inventory
    |> Map.put(:held_items, held_items)
  end

  defp populate_worn_items(inventory, character_id) do
    worn_items = Character.list_worn_items(character_id)

    container_nodes = Enum.filter(worn_items, & &1.is_container)

    Map.put(inventory, :worn_containers, container_nodes)
  end
end
