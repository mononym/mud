defmodule MudWeb.Live.Components.Svg do
  use Phoenix.Component

  def map(assigns) do
    ~H"""
    <svg class="w-full h-full" viewbox={@viewbox}>
      <%= for path <- @paths do %>
        <%= if path.has_marker do %>
          <defs>
            <marker
              id={"markerArrow-#{path.id}"}
              markerWidth={path.line_width * 2}
              markerHeight={path.line_width * 2}
              refX={path.line_width * 2 + path.marker_offset}
              refY={path.line_width}
              orient="auto"
            >
              <polygon
                points={"0 0, #{path.line_width *
                  2} {path.line_width}, 0 {path.line_width * 2}"}
                fill={path.marker_color}
              />
            </marker>
          </defs>
        <% end %>
        <path d={"M #{path.x1} #{path.y1} #{path.x2} #{path.y2}"} stroke={path.line_color} stroke-dasharray={if path.line_dashed, do: path.line_dash, else: ""}, stroke-width={path.line_width}, marker-end={if path.has_marker, do: "url(#markerArrow-#{path.id}", else: ""}, id={path.id} />
      <% end %>
      <%= for square <- @area_squares do %>
        <rect x={square.x} y={square.y} width={square.width} height={square.height}, rx={square.corners}, fill={square.fill}, stroke-width={square.border_width} stroke={square.border_color} class={square.cursor} id={square.id}>
          <title><%= square.name %></title>
        </rect>
      <% end %>
      <%= for label <- @text_labels do %>
        <text x={label.x} y={label.y} text-anchor="middle" fill={label.color} dominant-baseline="central" font-size={label.font_size} font-family="fantasy, sans-sarif", font-weight={label.font_weight}, font-style="normal", transform={label.transform}>
          <%= for {text, index} <- Enum.with_index(label.text) do %>
            <tspan x={label.x} y={label.y} dy={"#{index * label.font_size}px"}><%= text %></tspan>
          <% end %>
        </text>
      <% end %>
    </svg>
    """
  end
end
