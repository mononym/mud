defmodule MudWeb.Live.Component.AreaOverview do
  use Phoenix.LiveComponent

  alias Ecto.Multi
  alias MudWeb.ClientData.AreaOverview
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
        event: nil
      )

    {:ok, socket, temporary_assigns: [event: nil]}
  end

  def preload(assigns_list) do
    Enum.map(assigns_list, fn assigns ->
      if Map.has_key?(assigns, :id) do
        assigns
        |> Map.put(:area_data, init_area_data(assigns.id, assigns.character_id))
        |> Map.put(:loading, false)
      else
        if Map.has_key?(assigns, :event) do
          data = assigns.area_data
          event = assigns.event
          things = event.things

          updated_data =
            case event.action do
              :add ->
                Enum.reduce(things, data, fn thing, data ->
                  add(data, thing)
                end)

              :remove ->
                Enum.reduce(things, data, fn thing, data ->
                  remove(data, thing)
                end)

              :update ->
                Enum.reduce(things, data, fn thing, data ->
                  modify(data, thing)
                end)
            end

          Map.put(assigns, :area_data, updated_data)
        else
          assigns
        end
      end
    end)
  end

  defp add(data, character = %Character{}) do
    chars = Map.put(data.characters, character.id, character)
    Map.put(data, :characters, chars)
  end

  defp add(data, link = %Link{}) do
    links = Map.put(data.exits, link.id, link)
    Map.put(data, :exits, links)
  end

  defp add(data, item = %Item{}) do
    items = Map.put(data.items, item.id, item)

    Map.put(data, :items, items)
    |> generate_child_index()
  end

  defp modify(data, character = %Character{}) do
    chars = Map.put(data.characters, character.id, character)
    Map.put(data, :characters, chars)
  end

  defp modify(data, link = %Link{}) do
    links = Map.put(data.exits, link.id, link)
    Map.put(data, :exits, links)
  end

  defp modify(data, item = %Item{}) do
    items = Map.put(data.items, item.id, item)

    Map.put(data, :items, items)
    |> generate_child_index()
  end

  defp remove(data, character = %Character{}) do
    chars = Map.delete(data.characters, character.id)
    Map.put(data, :characters, chars)
  end

  defp remove(data, link = %Link{}) do
    links = Map.delete(data.exits, link.id)
    Map.put(data, :exits, links)
  end

  defp remove(data, item = %Item{}) do
    items = Map.delete(data.items, item.id)

    Map.put(data, :items, items)
    |> generate_child_index()
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

  defp init_area_data(area_id, character_id) do
    {:ok, returns} =
      Multi.new()
      |> Area.get_area!(:area, area_id)
      |> Character.list_others_active_in_areas(:others, character_id, area_id)
      |> Item.list_visible_scenery_in_area(:scenery, area_id)
      |> Item.list_non_scenery_in_areas(:items, area_id)
      |> Link.list_obvious_exits_in_area(:exits, area_id)
      |> Mud.Repo.transaction()

    %AreaOverview{}
    |> populate_area(returns[:area])
    |> populate_others(returns[:others])
    |> populate_toi(returns[:scenery])
    |> populate_items(returns[:items])
    |> populate_exits(returns[:exits])
    |> generate_child_index()
  end

  defp populate_area(overview, area) do
    %{overview | area: area}
  end

  defp populate_others(overview, characters) do
    %{overview | characters: to_index(characters)}
  end

  defp populate_toi(overview, toi) do
    %{overview | things_of_interest: to_index(toi)}
  end

  defp populate_items(overview, items) do
    %{overview | items: to_index(items)}
  end

  defp populate_exits(overview, exits) do
    %{overview | exits: to_index(exits)}
  end

  defp to_index(things) do
    Map.new(things, fn thing ->
      {thing.id, thing}
    end)
  end

  defp generate_child_index(area_overview) do
    all_items = Map.values(area_overview.items)

    item_child_index =
      Enum.reduce(all_items, %{}, fn item, map ->
        value = [item.id | Map.get(map, item.container_id, [])]
        Map.put(map, item.container_id, value)
      end)

    Map.put(area_overview, :item_child_index, item_child_index)
  end
end
