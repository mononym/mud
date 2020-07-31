defmodule MudWeb.Live.Component.RegionMap do
  use Phoenix.LiveComponent
  alias Mud.Engine.{Area, Link, Region, Script}
  alias Ecto.Multi

  @zoom_size_increment 500

  @viewbox_min_size 500
  @viewbox_max_size 3000

  @canvas_size 6000
  @canvas_coord @canvas_size / 2 - @viewbox_min_size / 2

  def mount(socket) do
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
        speed: "walk",
        follow: "always"
      )

    {:ok, socket, temporary_assigns: [event: nil]}
  end

  def update(assigns, socket) do
    socket =
      cond do
        not socket.assigns.initialized and Map.has_key?(assigns, :character) ->
          state = Ecto.Changeset.fetch_field!(assigns.client_state, :state)

          socket =
            if Map.has_key?(state, "region map") do
              load_state(state["region map"], socket)
            else
              socket
            end

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

    assign(socket,
      lines: lines,
      squares: squares
    )
    |> center_map()
  end

  defp center_map(socket) do
    cond do
      socket.assigns.follow == "always" ->
        center_map_on_character(socket)

      socket.assigns.follow == "sometimes" and viewbox_can_contain_everything(socket) ->
        center_map_in_region(socket)

      socket.assigns.follow == "sometimes" and not viewbox_can_contain_everything(socket) ->
        center_map_on_character(socket)

      socket.assigns.follow == "never" and viewbox_can_contain_everything(socket) ->
        center_map_in_region(socket)

      socket.assigns.follow == "never" and not viewbox_can_contain_everything(socket) ->
        socket
    end
  end

  defp viewbox_can_contain_everything(socket) do
    dimensions = calculate_dimensions_of_region(socket)

    max_size = max(dimensions.max_x - dimensions.min_x, dimensions.max_y - dimensions.min_y)

    max_size <= socket.assigns.viewbox_size * 0.8
  end

  defp calculate_dimensions_of_region(socket) do
    Enum.reduce(
      socket.assigns.areas,
      %{
        min_x: @canvas_size,
        min_y: @canvas_size,
        max_x: 0,
        max_y: 0
      },
      fn {_id, area}, dimensions ->
        dimensions =
          if area.map_x - area.map_size / 2 < dimensions.min_x do
            Map.put(dimensions, :min_x, area.map_x - area.map_size / 2)
          else
            dimensions
          end

        dimensions =
          if area.map_x + area.map_size / 2 > dimensions.max_x do
            Map.put(dimensions, :max_x, area.map_x + area.map_size / 2)
          else
            dimensions
          end

        dimensions =
          if area.map_y + area.map_size / 2 > dimensions.max_y do
            Map.put(dimensions, :max_y, area.map_y + area.map_size / 2)
          else
            dimensions
          end

        if area.map_y - area.map_size / 2 < dimensions.min_y do
          Map.put(dimensions, :min_y, area.map_y - area.map_size / 2)
        else
          dimensions
        end
      end
    )
  end

  defp center_map_in_region(socket) do
    dimensions = calculate_dimensions_of_region(socket)

    size_x = dimensions.max_x - dimensions.min_x
    size_y = dimensions.max_y - dimensions.min_y

    center_region_x = size_x / 2 + dimensions.min_x
    center_region_y = size_y / 2 + dimensions.min_y

    viewbox_x = center_region_x - socket.assigns.viewbox_size / 2
    viewbox_y = center_region_y - socket.assigns.viewbox_size / 2

    assign(socket,
      viewbox_x: viewbox_x,
      viewbox_y: viewbox_y
    )
  end

  defp center_map_on_character(socket) do
    {_id, active_area} =
      Enum.find(socket.assigns.areas, fn {id, _area} -> id == socket.assigns.character.area_id end)

    assign(socket,
      viewbox_x: active_area.map_x - socket.assigns.viewbox_size / 2,
      viewbox_y: active_area.map_y - socket.assigns.viewbox_size / 2
    )
  end

  def handle_event("zoom", %{"direction" => dir}, socket) do
    calculate_zoom(socket, dir)
  end

  def handle_event("set_auto_travel_speed", %{"speed" => speed}, socket) do
    Script.cast(socket.assigns.character, "auto_travel", {:update_speed, speed})

    socket =
      assign(
        socket,
        speed: speed
      )

    send(self(), {:update_client_state, "region map", dump_state(socket)})

    {:noreply, socket}
  end

  def handle_event("set_follow", %{"follow" => follow}, socket) do
    socket =
      assign(
        socket,
        follow: follow
      )

    send(self(), {:update_client_state, "region map", dump_state(socket)})

    socket = draw_map(socket)

    {:noreply, socket}
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

    socket =
      socket
      |> assign(
        viewbox_size: size,
        zoom_in_disabled: size == @viewbox_min_size,
        zoom_out_disabled: size == @viewbox_max_size,
        viewbox_x: socket.assigns.viewbox_x + @zoom_size_increment / 2,
        viewbox_y: socket.assigns.viewbox_y + @zoom_size_increment / 2
      )
      |> center_map()

    send(self(), {:update_client_state, "region map", dump_state(socket)})

    {:noreply, socket}
  end

  defp calculate_zoom(socket, "out") do
    assigns = socket.assigns
    size = min(assigns.viewbox_size + @zoom_size_increment, @viewbox_max_size)

    socket =
      socket
      |> assign(
        viewbox_size: size,
        zoom_in_disabled: size == @viewbox_min_size,
        zoom_out_disabled: size == @viewbox_max_size,
        viewbox_x: socket.assigns.viewbox_x - @zoom_size_increment / 2,
        viewbox_y: socket.assigns.viewbox_y - @zoom_size_increment / 2
      )
      |> center_map()

    send(self(), {:update_client_state, "region map", dump_state(socket)})

    {:noreply, socket}
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

  defp dump_state(socket) do
    %{
      follow: socket.assigns.follow,
      speed: socket.assigns.speed,
      viewbox_size: socket.assigns.viewbox_size,
      zoom_in_disabled: socket.assigns.zoom_in_disabled,
      zoom_out_disabled: socket.assigns.zoom_out_disabled
    }
  end

  defp load_state(state, socket) do
    assign(socket,
      speed: state.speed,
      viewbox_size: state.viewbox_size,
      follow: state.follow,
      zoom_in_disabled: state.zoom_in_disabled,
      zoom_out_disabled: state.zoom_out_disabled
    )
  end
end
