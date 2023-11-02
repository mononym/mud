defmodule MudWeb.PlayLive.MapPanel do
  use MudWeb, :live_component

  alias Ecto.Changeset
  alias Mud.Engine.{Area}
  alias Mud.Engine
  alias Mud.Engine.Character.Settings
  alias MudWeb.PlayLive.Util
  alias Mud.Engine.Event.Client.UpdateCharacter
  alias MudWeb.Live.Components.Svg
  alias MudWeb.MapLive.SvgMap

  import MudWeb.PlayLive.Util
  import MudWeb.PlayLive.Components

  require Logger

  # held items
  # worn containers
  # worn items
  # slots

  @impl true
  def mount(socket) do
    {:ok,
     assign(socket,
       focus_area_id: nil,
       # A set of all of the areas which should be highlighted. For example an area that is focused on may or may not be highlighted.
       highlighted_area_ids: MapSet.new(),
       # A set of all of the links which should be highlighted. For example a link that is selected may or may not be highlighted.
       highlighted_link_ids: MapSet.new(),
       # Controls display and code behavior when it comes to selecting different types of areas
       allow_inter_map_area_selection: false,
       allow_intra_map_area_selection: false,
       zoom_multiplier: 1,
       # Aspect ratio
       svg_wrapper_width: 16,
       svg_wrapper_height: 9,
       # Links between all the areas in the map and those between the displayed map and linked maps.
       links: %{},
       # All of the areas to be drawn on the map along with the 'external' areas that are linked to
       # from within the map.
       areas: %{},
       # All of the areas that the character knows about. This may or may not be all of the areas
       # belonging to a single map.
       explored_areas: MapSet.new(),
       map: %Engine.Map{},
       viewbox: "",
       # Whether or not to focus on an area. Used for toggling area focus or letting user manually center map.
       focus_on_area: true,
       # Text labels built from the %Label{} models for ease of insertion into the map
       text_labels: [],
       area_squares: []
     )}
  end

  @impl true
  def update(assigns, socket) do
    socket = assign(socket, assigns)

    {:ok, process_map_data(socket)}
  end

  @impl true
  def handle_event("set_map_dimensions", %{"width" => width, "height" => height} = params, socket) do
    {:noreply,
     assign(socket,
       svg_wrapper_width: width,
       svg_wrapper_height: height
     )
     |> build_viewbox()}
  end

  @impl true
  def handle_event("zoom_out", _params, socket) do
    {:noreply,
     assign(socket,
       zoom_multiplier: min(socket.assigns.zoom_multiplier * 2, 8)
     )
     |> build_viewbox()}
  end

  @impl true
  def handle_event("zoom_in", _params, socket) do
    {:noreply,
     assign(socket,
       zoom_multiplier: max(socket.assigns.zoom_multiplier * 0.5, 0.25)
     )
     |> build_viewbox()}
  end

  #
  # Internal Functions
  #

  defp process_map_data(socket) do
    socket
    |> build_viewbox()
    # Labels for the current map which already exist (ie. not currently being created)
    |> build_existing_map_labels()
    |> build_existing_intra_map_areas()
    |> build_existing_inter_map_areas()
    |> build_highlights_for_existing_intra_map_areas()
    |> build_highlights_for_existing_inter_map_areas()
    |> build_existing_intra_map_links()
    |> build_existing_inter_map_links()
    |> build_existing_intra_map_link_labels()
    |> build_existing_unexplored_intra_map_links()
    |> build_existing_unexplored_inter_map_links()
  end

  defp build_existing_unexplored_intra_map_links(socket) do
    areas = socket.assigns.areas
    map = socket.assigns.maps[socket.assigns.map]
    explored_areas = socket.assigns.explored_areas

    paths =
      Enum.filter(
        Map.values(socket.assigns.links),
        &(areas[&1.from_id].map_id == map.id and areas[&1.to_id].map_id == map.id and
            MapSet.member?(explored_areas, &1.from_id) and
            not MapSet.member?(explored_areas, &1.to_id))
      )
      |> Enum.map(fn link ->
        build_unexplored_path_from_link(
          link,
          map,
          areas[link.from_id].map_x,
          areas[link.from_id].map_y,
          areas[link.to_id].map_x,
          areas[link.to_id].map_y
        )
      end)

    assign(socket, paths: paths ++ socket.assigns.paths)
  end

  defp build_existing_unexplored_inter_map_links(socket) do
    areas = socket.assigns.areas
    map = socket.assigns.maps[socket.assigns.map]
    explored_areas = socket.assigns.explored_areas

    paths =
      Enum.filter(
        Map.values(socket.assigns.links),
        &(areas[&1.from_id].map_id == map.id and areas[&1.to_id].map_id != map.id and
            MapSet.member?(explored_areas, &1.from_id) and
            not MapSet.member?(explored_areas, &1.to_id))
      )
      |> Enum.map(fn link ->
        build_unexplored_path_from_link(
          link,
          map,
          areas[link.from_id].map_x,
          areas[link.from_id].map_y,
          link.local_to_x,
          link.local_to_y
        )
      end)

    assign(socket, paths: paths ++ socket.assigns.paths)
  end

  defp build_unexplored_path_from_link(link, map, from_x, from_y, to_x, to_y) do
    grid_size = map.grid_size
    view_size = map.view_size

    x1 = from_x * grid_size + view_size / 2
    y1 = -from_y * grid_size + view_size / 2
    x2 = to_x * grid_size + view_size / 2
    y2 = -to_y * grid_size + view_size / 2

    x3 = (x1 + x2) / 2
    y3 = (y1 + y2) / 2

    %{
      id: link.id,
      x1: x1,
      y1: y1,
      x2: x3,
      y2: y3,
      line_width: link.line_width,
      line_color: link.line_color,
      line_dash: link.line_dash,
      line_dashed: link.line_dashed,
      has_marker: false,
      marker_offset: link.marker_offset,
      marker_color: link.line_color,
      marker_width: link.line_width * 3,
      marker_height: link.line_width * 3
    }
  end

  defp build_existing_intra_map_link_labels(socket) do
    areas = socket.assigns.areas
    map = socket.assigns.maps[socket.assigns.map]
    explored_areas = socket.assigns.explored_areas

    labels =
      Enum.filter(
        Map.values(socket.assigns.links),
        &(areas[&1.to_id].map_id == map.id and areas[&1.from_id].map_id == map.id and
            MapSet.member?(explored_areas, &1.to_id) and
            MapSet.member?(explored_areas, &1.from_id) and &1.label != "")
      )
      |> Enum.map(fn link ->
        build_label_from_link(
          link,
          map,
          socket.assigns.areas[link.from_id].map_x,
          socket.assigns.areas[link.from_id].map_y,
          socket.assigns.areas[link.to_id].map_x,
          socket.assigns.areas[link.to_id].map_y
        )
      end)

    assign(socket, text_labels: labels ++ socket.assigns.text_labels)
  end

  defp build_label_from_link(link, map, from_x, from_y, to_x, to_y) do
    horizontal_position = (from_x + to_x) / 2 * map.grid_size + map.view_size / 2

    vertical_position = -((from_y + to_y) / 2) * map.grid_size + map.view_size / 2

    label_transform =
      "translate(#{link.label_horizontal_offset}, -#{link.label_vertical_offset}) rotate(#{link.label_rotation}, #{horizontal_position}, #{vertical_position})"

    %{
      id: "#{link.id}-text",
      text: String.split(link.label, ~r/\n/),
      transform: label_transform,
      font_size: link.label_font_size,
      # TODO: Add label weight to links
      font_weight: 50,
      x: horizontal_position,
      y: vertical_position,
      color: link.label_color
    }
  end

  defp build_existing_intra_map_links(socket) do
    areas = socket.assigns.areas
    map = socket.assigns.maps[socket.assigns.map]
    explored_areas = socket.assigns.explored_areas

    paths =
      Enum.filter(
        Map.values(socket.assigns.links),
        &(areas[&1.to_id].map_id == map.id and areas[&1.from_id].map_id == map.id and
            MapSet.member?(explored_areas, &1.to_id) and
            MapSet.member?(explored_areas, &1.from_id))
      )
      |> Enum.map(
        &build_full_path_from_link(
          &1,
          map,
          areas[&1.from_id].map_x,
          areas[&1.from_id].map_y,
          areas[&1.to_id].map_x,
          areas[&1.to_id].map_y
        )
      )

    assign(socket, paths: paths)
  end

  defp build_existing_inter_map_links(socket) do
    areas = socket.assigns.areas
    map = socket.assigns.maps[socket.assigns.map]
    explored_areas = socket.assigns.explored_areas

    paths =
      Enum.filter(
        Map.values(socket.assigns.links),
        &(((areas[&1.to_id].map_id != map.id and areas[&1.from_id].map_id == map.id) or
             (areas[&1.to_id].map_id == map.id and areas[&1.from_id].map_id != map.id)) and
            MapSet.member?(explored_areas, &1.to_id) and
            MapSet.member?(explored_areas, &1.from_id))
      )
      |> Enum.map(fn link ->
        {link, coords} =
          if areas[link.to_id].map_id == map.id do
            {%{
               link
               | label: link.local_from_label,
                 label_font_size: link.local_from_label_font_size,
                 label_horizontal_offset: link.local_from_label_horizontal_offset,
                 label_vertical_offset: link.local_from_label_vertical_offset,
                 label_rotation: link.local_from_label_rotation,
                 label_color: link.local_from_label_color
             },
             %{
               from_x: link.local_from_x,
               from_y: link.local_from_y,
               to_x: areas[link.to_id].map_x,
               to_y: areas[link.to_id].map_y
             }}
          else
            {%{
               link
               | label: link.local_to_label,
                 label_font_size: link.local_to_label_font_size,
                 label_horizontal_offset: link.local_to_label_horizontal_offset,
                 label_vertical_offset: link.local_to_label_vertical_offset,
                 label_rotation: link.local_to_label_rotation,
                 label_color: link.local_to_label_color
             },
             %{
               from_x: areas[link.from_id].map_x,
               from_y: areas[link.from_id].map_y,
               to_x: link.local_to_x,
               to_y: link.local_to_y
             }}
          end

        build_full_path_from_link(
          link,
          map,
          coords.from_x,
          coords.from_y,
          coords.to_x,
          coords.to_y
        )
      end)

    assign(socket, paths: paths ++ socket.assigns.paths)
  end

  defp build_full_path_from_link(link, map, from_x, from_y, to_x, to_y) do
    grid_size = map.grid_size
    view_size = map.view_size

    %{
      id: link.id,
      x1: from_x * grid_size + view_size / 2,
      y1: -from_y * grid_size + view_size / 2,
      x2: to_x * grid_size + view_size / 2,
      y2: -to_y * grid_size + view_size / 2,
      line_width: link.line_width,
      line_color: link.line_color,
      line_dash: link.line_dash,
      line_dashed: link.line_dashed,
      has_marker: link.has_marker,
      marker_offset: link.marker_offset,
      marker_color: link.line_color,
      marker_width: link.line_width * 3,
      marker_height: link.line_width * 3
    }
  end

  defp build_existing_intra_map_areas(socket) do
    rectangles =
      Enum.filter(
        Map.values(socket.assigns.areas),
        &(&1.map_id == socket.assigns.map and
            MapSet.member?(socket.assigns.explored_areas, &1.id))
      )
      |> Enum.map(
        &build_rect_from_area(
          &1,
          socket.assigns.maps[socket.assigns.map],
          socket.assigns.allow_intra_map_area_selection
        )
      )

    assign(socket, area_squares: rectangles)
  end

  defp build_existing_inter_map_areas(socket) do
    rectangles =
      Enum.filter(
        Map.values(socket.assigns.areas),
        &(&1.map_id != socket.assigns.map and
            MapSet.member?(socket.assigns.explored_areas, &1.id))
      )
      |> Enum.map(fn area ->
        link =
          Enum.find(Map.values(socket.assigns.links), fn link ->
            link.to_id == area.id or link.from_id == area.id
          end)

        # Outgoing link to other area.
        # Use 'local to'
        area =
          if link.to_id == area.id do
            %{
              area
              | map_size: link.local_to_size,
                map_corners: link.local_to_corners,
                color: link.local_to_color,
                border_color: link.local_to_border_color,
                border_width: link.local_to_border_width,
                map_x: link.local_to_x,
                map_y: link.local_to_y,
                name: "#{socket.assigns.maps[area.map_id].name}, #{area.name}"
            }
          else
            %{
              area
              | map_size: link.local_from_size,
                map_corners: link.local_from_corners,
                color: link.local_from_color,
                border_color: link.local_from_border_color,
                border_width: link.local_from_border_width,
                map_x: link.local_from_x,
                map_y: link.local_from_y,
                name: "#{socket.assigns.maps[area.map_id].name}, #{area.name}"
            }
          end

        build_rect_from_area(
          area,
          socket.assigns.maps[socket.assigns.map],
          socket.assigns.allow_inter_map_area_selection
        )
      end)

    assign(socket, area_squares: rectangles ++ socket.assigns.area_squares)
  end

  defp build_highlights_for_existing_intra_map_areas(socket) do
    rectangles =
      Enum.filter(
        Map.values(socket.assigns.areas),
        &(&1.map_id == socket.assigns.map and
            MapSet.member?(socket.assigns.highlighted_area_ids, &1.id) and
            MapSet.member?(socket.assigns.explored_areas, &1.id))
      )
      |> Enum.map(fn area ->
        updated_area = modify_area_for_highlight(socket, area)

        build_rect_from_area(
          updated_area,
          socket.assigns.maps[socket.assigns.map],
          socket.assigns.allow_intra_map_area_selection
        )
      end)

    assign(socket, area_squares: rectangles ++ socket.assigns.area_squares)
  end

  defp build_highlights_for_existing_inter_map_areas(socket) do
    rectangles =
      Enum.filter(
        Map.values(socket.assigns.areas),
        &(&1.map_id != socket.assigns.map and
            MapSet.member?(socket.assigns.highlighted_area_ids, &1.id) and
            MapSet.member?(socket.assigns.explored_areas, &1.id))
      )
      |> Enum.map(fn area ->
        updated_area = modify_area_for_highlight(socket, area)

        build_rect_from_area(
          updated_area,
          socket.assigns.maps[socket.assigns.map],
          socket.assigns.allow_intra_map_area_selection
        )
      end)

    assign(socket, area_squares: rectangles ++ socket.assigns.area_squares)
  end

  defp modify_area_for_highlight(socket, area) do
    %{
      area
      | map_size: area.map_size + 5,
        border_color: socket.assigns.map_settings.highlighted_area_color,
        color: socket.assigns.map_settings.highlighted_area_color,
        border_width: max(5, area.border_width + 2),
        id: "#{area.id}-highlight"
    }
  end

  defp build_rect_from_area(area, map, allow_selection) do
    cursor =
      if allow_selection do
        "cursor-pointer"
      else
        "cursor-auto"
      end

    %{
      id: area.id,
      x: area.map_x * map.grid_size + map.view_size / 2 - area.map_size / 2,
      y: -area.map_y * map.grid_size + map.view_size / 2 - area.map_size / 2,
      width: area.map_size,
      height: area.map_size,
      corners: area.map_corners,
      fill: area.color,
      name: area.name,
      cursor: cursor,
      border_color: area.border_color,
      border_width: area.border_width,
      allow_selection: allow_selection
    }
  end

  defp build_existing_map_labels(socket) do
    map = socket.assigns.maps[socket.assigns.map]

    labels =
      Enum.map(
        socket.assigns.labels,
        fn label ->
          horizontal_position = label.x * map.grid_size + map.view_size / 2

          vertical_position = -label.y * map.grid_size + map.view_size / 2

          label_transform =
            "translate(#{label.horizontal_offset}, -#{label.vertical_offset}) rotate(#{label.rotation}, #{horizontal_position}, #{vertical_position})"

          %{
            id: label.id,
            text: String.split(label.text, ~r/\n/),
            transform: label_transform,
            font_size: label.size,
            font_weight: label.weight,
            x: horizontal_position,
            y: vertical_position,
            color: label.color
          }
        end
      )

    assign(socket, text_labels: labels)
  end

  defp build_viewbox(socket) do
    assigns = socket.assigns
    map = socket.assigns.maps[socket.assigns.map] || %Engine.Map{}

    x_center_point =
      if assigns.focus_on_area and not is_nil(assigns.focus_area_id) and assigns.areas != %{} do
        assigns.areas[assigns.focus_area_id].map_x * map.grid_size +
          map.view_size / 2
      else
        map.view_size / 2
      end

    y_center_point =
      if assigns.focus_on_area and not is_nil(assigns.focus_area_id) and assigns.areas != %{} do
        -assigns.areas[assigns.focus_area_id].map_y * map.grid_size +
          map.view_size / 2
      else
        map.view_size / 2
      end

    viewbox_x_size = map.view_size * assigns.zoom_multiplier

    # viewbox_y_size =
    #   max(
    #     map.view_size * (assigns.svg_wrapper_width / assigns.svg_wrapper_height) *
    #       assigns.zoom_multiplier,
    #     0
    #   )
    viewbox_y_size = map.view_size * assigns.zoom_multiplier

    viewbox_x = x_center_point - viewbox_x_size / 2
    viewbox_y = y_center_point - viewbox_y_size / 2

    assign(socket, viewbox: "#{viewbox_x} #{viewbox_y} #{viewbox_x_size} #{viewbox_y_size}")
  end
end
