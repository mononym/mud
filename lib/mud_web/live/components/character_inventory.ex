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
        :containers_expanded,
        true
      )
      |> assign(
        :held_expanded,
        true
      )
      |> assign(
        :loading,
        true
      )

    {:ok, socket}
  end

  def preload(list_of_assigns) do
    list_of_ids =
      Enum.map(list_of_assigns, fn assigns ->
        assigns.character_id
      end)

    characters =
      list_of_ids
      |> Character.list()
      |> Enum.reduce(%{}, fn character, map ->
        Map.put(map, character.id, character)
      end)

    Enum.map(list_of_assigns, fn assigns ->
      character = characters[assigns.character_id]
      inventory_data = init_inventory_data(character)

      assigns
      |> Map.put(:inventory_data, inventory_data)
      |> Map.put(:loading, false)
    end)
  end

  def render(assigns) do
    Phoenix.View.render(MudWeb.MudClientView, "character_inventory.html", assigns)
  end

  def handle_event("toggle_containers", _, socket) do
    Logger.debug("toggle_containers")

    {:noreply,
     assign(
       socket,
       :containers_expanded,
       not socket.assigns.containers_expanded
     )}
  end

  def handle_event("toggle_container", _, socket) do
    Logger.debug("toggle_container")

    {:noreply,
     assign(
       socket,
       :containers_expanded,
       not socket.assigns.containers_expanded
     )}
  end

  defp init_inventory_data(character) do
    inv =
      %Inventory{}
      |> populate_held_items(character)
      |> populate_worn_items(character)

    root_items = (inv.held_items ++ inv.worn_containers) |> Enum.filter(&(not is_nil(&1)))

    all_items =
      Engine.Item.list_all_recursive(root_items)
      |> Enum.reduce(%{}, fn item, map ->
        value = [item | Map.get(map, item.container_id, [])]
        Map.put(map, item.container_id, value)
      end)

    Map.put(inv, :item_child_index, all_items)
  end

  defp populate_held_items(inventory, character) do
    held_items =
      Character.list_held_items(character.id)
      |> Enum.map(fn item -> transform_item(item, character) end)

    inventory
    |> Map.put(:held_items, held_items)
  end

  defp populate_worn_items(inventory, character) do
    worn_items = Character.list_worn_items(character.id)

    container_nodes =
      Enum.filter(worn_items, & &1.is_container)
      |> Enum.map(fn item -> transform_item(item, character) end)

    all_items =
      Engine.Item.list_all_recursive(worn_items)
      |> Enum.map(fn item -> transform_item(item, character) end)

    all_items_index = build_container_item_index(all_items)

    inventory
    |> Map.put(:worn_containers, container_nodes)
    |> Map.put(:worn_container_item_index, all_items_index)
  end

  defp build_container_item_index(nodes) do
    Enum.reduce(nodes, %{}, fn node, map ->
      children = [node | Map.get(node, node.parent, [])]
      Map.put(map, node.parent, children)
    end)
  end

  defp transform_item(item, character) do
    icon = choose_icon(item)

    %Inventory.Item{
      short_description: Mud.Engine.Item.short_description(item, character),
      long_description: Mud.Engine.Item.short_look(item, character),
      id: item.id,
      opened: item.container_open,
      parent: item.container_id,
      icon: icon,
      openable: item.is_container
    }
  end

  defp choose_icon(_), do: "fas fa-question"
end
