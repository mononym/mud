defmodule MudWeb.Live.Component.Map do
  use Phoenix.LiveComponent
  alias Mud.Engine.{Area, Link, Region, Script}
  alias Ecto.Multi

  @zoom_coordinate_increment 250
  @zoom_size_increment 500

  @viewbox_min_size 500
  @viewbox_max_size 3000

  @canvas_size 6000
  @canvas_coord @canvas_size / 2 - @viewbox_min_size / 2

  def mount(socket) do
    IO.inspect("mount")

    socket =
      socket
      |> assign(
        links: %{},
        areas: %{},
        viewbox_x: @canvas_coord,
        viewbox_y: @canvas_coord,
        viewbox_size: @viewbox_min_size,
        event: nil,
        initialized: false,
        zoom_in_disabled: true,
        zoom_out_disabled: false,
        graph: nil,
        speed: "walk"
      )

    {:ok, socket, temporary_assigns: [event: nil]}
  end

  def update(assigns, socket) do
    socket =
      cond do
        not socket.assigns.initialized and Map.has_key?(assigns, :character) ->
          socket
          |> assign(:character, assigns.character)
          |> init_map_data()
          |> assign(:initialized, true)

        Map.has_key?(assigns, :character) ->
          if Map.has_key?(socket.assigns.areas, assigns.character.area_id) do
            socket
            |> assign(:character, assigns.character)
            |> draw_map()
          else
            socket
            |> assign(:character, assigns.character)
            |> init_map_data()
          end

        true ->
          socket
      end

    {:ok, socket}
  end

  def render(assigns) do
    Phoenix.View.render(MudWeb.MudClientMapView, "map.html", assigns)
  end

  def draw_map(socket) do
    assigns = socket.assigns

    lines =
      Enum.map(assigns.links, fn {_id, link} ->
        from = assigns.areas[link.from_id]
        to = assigns.areas[link.to_id]

        x_to =
          if from.map_x < to.map_x do
            (to.map_x - (to.map_x - from.map_x) / 2) |> floor()
          else
            (from.map_x + (to.map_x - from.map_x) / 2) |> floor()
          end

        y_to =
          if from.map_y < to.map_y do
            (to.map_y - (to.map_y - from.map_y) / 2) |> floor()
          else
            (from.map_y + (to.map_y - from.map_y) / 2) |> floor()
          end

        %{
          x1: from.map_x,
          y1: from.map_y,
          x2: x_to,
          y2: y_to
        }
      end)

    squares =
      Enum.map(assigns.areas, fn {_id, area} ->
        %{
          id: area.id,
          x: area.map_x - area.map_size / 2,
          y: area.map_y - area.map_size / 2,
          size: area.map_size,
          name: area.name,
          color:
            if area.id == assigns.character.area_id do
              "green"
            else
              "blue"
            end
        }
      end)

    assign(socket, lines: lines, squares: squares)
  end

  def handle_event("zoom", %{"direction" => dir}, socket) do
    calculate_zoom(socket, dir)
  end

  def handle_event("set_auto_travel_speed", %{"speed" => speed}, socket) do
    Script.cast(socket.assigns.character, "auto_travel", {:update_speed, speed})

    {:noreply,
     assign(
       socket,
       speed: speed
     )}
  end

  def handle_event("auto_travel", %{"destination" => destination}, socket) do
    area = Area.get_area!(destination)

    raw_data = Region.list_area_and_link_ids(area.region_id)

    raw_data =
      Map.put(
        raw_data,
        :link_ids,
        Enum.map(raw_data[:link_ids], fn {lid, l1, l2} ->
          {l1, l2, [label: lid, weight: 1]}
        end)
      )

    graph =
      Graph.new(type: :directed)
      |> Graph.add_edges(raw_data[:link_ids])
      |> Graph.add_vertices(raw_data[:area_ids])

    path = Graph.dijkstra(graph, socket.assigns.character.area_id, area.id)

    :ok =
      Script.attach(socket.assigns.character, "auto_travel", Script.Travel, %{
        path: path,
        speed: socket.assigns.speed
      })

    {:noreply, socket}
  end

  defp calculate_zoom(socket, "in") do
    assigns = socket.assigns
    size = max(assigns.viewbox_size - @zoom_size_increment, @viewbox_min_size)

    {x, y} =
      if size == assigns.viewbox_size do
        {assigns.viewbox_x, assigns.viewbox_y}
      else
        {assigns.viewbox_x + @zoom_coordinate_increment,
         assigns.viewbox_x + @zoom_coordinate_increment}
      end

    {:noreply,
     assign(
       socket,
       viewbox_x: x,
       viewbox_y: y,
       viewbox_size: size,
       zoom_in_disabled: size == @viewbox_min_size,
       zoom_out_disabled: size == @viewbox_max_size
     )}
  end

  defp calculate_zoom(socket, "out") do
    assigns = socket.assigns
    size = min(assigns.viewbox_size + @zoom_size_increment, @viewbox_max_size)

    {x, y} =
      if size == assigns.viewbox_size do
        {assigns.viewbox_x, assigns.viewbox_y}
      else
        {assigns.viewbox_x - @zoom_coordinate_increment,
         assigns.viewbox_x - @zoom_coordinate_increment}
      end

    {:noreply,
     assign(
       socket,
       viewbox_x: x,
       viewbox_y: y,
       viewbox_size: size,
       zoom_in_disabled: size == @viewbox_min_size,
       zoom_out_disabled: size == @viewbox_max_size
     )}
  end

  defp init_map_data(socket) do
    area_id = socket.assigns.character.area_id

    {:ok, returns} =
      Multi.new()
      |> UberMulti.run(:region, [area_id], &Region.get_from_area!/1, true)
      |> UberMulti.run(:areas, [:region], &Area.list_in_region/1, true)
      |> UberMulti.run(:links, [:region], &Link.list_in_region/1, true)
      |> Mud.Repo.transaction()

    socket
    |> populate_region(returns[:region])
    |> populate_areas(returns[:areas])
    |> populate_links(returns[:links])
    |> draw_map()
  end

  defp populate_region(socket, region) do
    assign(
      socket,
      region: region
    )
  end

  defp populate_areas(socket, areas) do
    assign(
      socket,
      areas: to_index(areas)
    )
  end

  defp populate_links(socket, links) do
    assign(
      socket,
      links: to_index(links)
    )
  end

  defp to_index(things) do
    Map.new(things, fn thing ->
      {thing.id, thing}
    end)
  end
end
