defmodule MudWeb.Live.Component.CharacterInventory do
  use Phoenix.LiveComponent

  alias Mud.Engine.Item
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

  def update(assigns, socket) do
    socket = assign(socket, Enum.to_list(assigns))

    socket =
      cond do
        not socket.assigns.initialized ->
          init_inventory_data(socket)
          |> assign(:initialized, true)
          |> assign(:loading, false)

        not is_nil(socket.assigns.event) ->
          event = socket.assigns.event
          items = event.items

          case event.action do
            :add ->
              Enum.reduce(items, socket, fn thing, socket ->
                modify(socket, thing)
              end)

            :remove ->
              Enum.reduce(items, socket, fn thing, socket ->
                remove(socket, thing)
              end)

            :update ->
              Enum.reduce(items, socket, fn thing, socket ->
                modify(socket, thing)
              end)
          end

        true ->
          socket
      end

    {:ok, socket}
  end

  defp modify(socket, item = %Item{}) do
    items = Map.put(socket.assigns.items, item.id, item)

    socket
    |> assign(:items, items)
    |> update_indexes()
  end

  defp remove(socket, item = %Item{}) do
    items = prune(socket.assigns.items, item.id, socket.assigns.item_child_index)

    socket
    |> assign(:items, items)
    |> update_indexes()
  end

  defp prune(items, item_id, child_index) do
    items =
      if Map.has_key?(items, item_id) do
        Map.delete(items, item_id)
      else
        items
      end

    Enum.reduce(child_index[item_id] || [], items, &prune(&2, &1, child_index))
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

  defp update_indexes(socket) do
    child_index = generate_child_index(Map.values(socket.assigns.items))

    grouped_items =
      Enum.group_by(
        Map.values(socket.assigns.items),
        fn item ->
          cond do
            item.holdable_is_held ->
              :held

            item.wearable_is_worn and item.is_container ->
              :container

            item.wearable_is_worn and not item.is_container ->
              :worn

            true ->
              :child
          end
        end,
        & &1.id
      )

    socket
    |> assign(:held_items, grouped_items[:held] || [])
    |> assign(:worn_containers, grouped_items[:container] || [])
    |> assign(:item_child_index, child_index)
  end

  defp init_inventory_data(socket) do
    all_items = Item.list_held_or_worn_items_and_children(socket.assigns.id)
    IO.inspect(all_items)

    socket
    |> assign(:items, to_index(all_items))
    |> update_indexes()
  end

  defp to_index(things) do
    Map.new(things, fn thing ->
      {thing.id, thing}
    end)
  end

  defp generate_child_index(all_items) do
    Enum.reduce(all_items, %{}, fn item, map ->
      value = [item.id | Map.get(map, item.container_id, [])]
      Map.put(map, item.container_id, value)
    end)
  end
end
