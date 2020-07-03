defmodule MudWeb.Live.Component.AreaOverview do
  use Phoenix.LiveComponent

  alias Ecto.Multi
  alias Mud.Engine.{Area, Character, Item, Link}
  require Logger

  def mount(socket) do
    socket =
      socket
      |> assign(
        description_expanded: true,
        exits_expanded: true,
        characters_expanded: true,
        things_expanded: true,
        items_expanded: true,
        loading: true,
        initialized: false,
        event: nil
      )

    {:ok, socket, temporary_assigns: [event: nil]}
  end

  defp add(socket, character = %Character{}) do
    chars = Map.put(socket.assigns.characters, character.id, character)
    assign(socket, :characters, chars)
  end

  defp add(socket, link = %Link{}) do
    links = Map.put(socket.assigns.exits, link.id, link)
    assign(socket, :exits, links)
  end

  defp add(socket, item = %Item{}) do
    if item.is_furniture do
      items = Map.put(socket.assigns.things_of_interest, item.id, item)

      socket
      |> assign(:things_of_interest, items)
      |> assign(:things_of_interest_child_index, generate_child_index(Map.values(items)))
    else
      items =
        if item.is_container do
          new_items = Item.list_all_recursive(item)
          Enum.reduce(new_items, socket.assigns.items, &Map.put(&2, &1.id, &1))
        else
          Map.put(socket.assigns.items, item.id, item)
        end

      socket
      |> assign(:items, items)
      |> assign(:item_child_index, generate_child_index(Map.values(items)))
    end
  end

  defp modify(socket, character = %Character{}) do
    chars = Map.put(socket.assigns.characters, character.id, character)
    assign(socket, :characters, chars)
  end

  defp modify(socket, link = %Link{}) do
    links = Map.put(socket.assigns.exits, link.id, link)
    assign(socket, :exits, links)
  end

  defp modify(socket, item = %Item{}) do
    add(socket, item)
  end

  defp remove(socket, character = %Character{}) do
    chars = Map.delete(socket.assigns.characters, character.id)
    assign(socket, :characters, chars)
  end

  defp remove(socket, link = %Link{}) do
    links = Map.delete(socket.assigns.exits, link.id)
    assign(socket, :exits, links)
  end

  defp remove(socket, item = %Item{}) do
    if item.is_furniture do
      items =
        prune(
          socket.assigns.things_of_interest,
          item.id,
          socket.assigns.things_of_interest_child_index
        )

      socket
      |> assign(:things_of_interest, items)
      |> assign(:things_of_interest_child_index, generate_child_index(Map.values(items)))
    else
      items = prune(socket.assigns.items, item.id, socket.assigns.item_child_index)

      socket
      |> assign(:items, items)
      |> assign(:item_child_index, generate_child_index(Map.values(items)))
    end
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

  def update(assigns, socket) do
    socket = assign(socket, Enum.to_list(assigns))

    socket =
      cond do
        not socket.assigns.initialized ->
          init_area_data(socket)
          |> assign(:initialized, true)
          |> assign(:loading, false)

        not is_nil(socket.assigns.event) ->
          event = socket.assigns.event
          things = event.things

          case event.action do
            :add ->
              Enum.reduce(things, socket, fn thing, socket ->
                add(socket, thing)
              end)

            :remove ->
              Enum.reduce(things, socket, fn thing, socket ->
                remove(socket, thing)
              end)

            :update ->
              Enum.reduce(things, socket, fn thing, socket ->
                modify(socket, thing)
              end)
          end

        true ->
          socket
      end

    {:ok, socket}
  end

  def render(assigns) do
    Phoenix.View.render(MudWeb.MudClientView, "area_overview.html", assigns)
  end

  def handle_event("toggle_exits", _, socket) do
    {:noreply,
     assign(
       socket,
       :exits_expanded,
       not socket.assigns.exits_expanded
     )}
  end

  def handle_event("toggle_characters", _, socket) do
    {:noreply,
     assign(
       socket,
       :characters_expanded,
       not socket.assigns.characters_expanded
     )}
  end

  def handle_event("toggle_toi", _, socket) do
    {:noreply,
     assign(
       socket,
       :things_expanded,
       not socket.assigns.things_expanded
     )}
  end

  def handle_event("toggle_ground", _, socket) do
    {:noreply,
     assign(
       socket,
       :items_expanded,
       not socket.assigns.items_expanded
     )}
  end

  def handle_event("toggle_description", _, socket) do
    {:noreply,
     assign(
       socket,
       :description_expanded,
       not socket.assigns.description_expanded
     )}
  end

  defp init_area_data(socket) do
    area_id = socket.assigns.id
    character_id = socket.assigns.character_id

    {:ok, returns} =
      Multi.new()
      |> Area.get_area!(:area, area_id)
      |> Character.list_others_active_in_areas(:others, character_id, area_id)
      |> Item.list_visible_scenery_in_area(:scenery, area_id)
      |> Item.list_non_scenery_in_areas(:items, area_id)
      |> Link.list_obvious_exits_in_area(:exits, area_id)
      |> Mud.Repo.transaction()

    socket
    |> populate_area(returns[:area])
    |> populate_others(returns[:others])
    |> populate_toi(Item.list_all_recursive(returns[:scenery]))
    |> populate_items(Item.list_all_recursive(returns[:items]))
    |> populate_exits(returns[:exits])
  end

  defp populate_area(socket, area) do
    assign(socket, :area, area)
  end

  defp populate_others(socket, characters) do
    assign(socket, :characters, to_index(characters))
  end

  defp populate_toi(socket, items) do
    indexed_items = to_index(items)

    socket
    |> assign(:things_of_interest, indexed_items)
    |> assign(:things_of_interest_child_index, generate_child_index(items))
  end

  defp populate_items(socket, items) do
    indexed_items = to_index(items)

    socket
    |> assign(:items, indexed_items)
    |> assign(:item_child_index, generate_child_index(items))
  end

  defp populate_exits(socket, exits) do
    assign(socket, :exits, to_index(exits))
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
