defmodule MudWeb.MapLive.PathComponent do
  use MudWeb, :live_component

  def render(assigns) do
    ~H"""
    <g>
      <%= if @path.has_marker do %>
        <defs>
          <marker
            id={"markerArrow-#{@path.id}"}
            markerWidth={@path.line_width * 2}
            markerHeight={@path.line_width * 2}
            refX={@path.line_width * 2 + @path.marker_offset}
            refY={@path.line_width}
            orient="auto"
          >
            <polygon
              points={"0 0, #{@path.line_width *
                2} #{@path.line_width}, 0 #{@path.line_width * 2}"}
              fill={@path.marker_color}
            />
          </marker>
        </defs>
      <% end %>
      <path d={"M #{@path.x1} #{@path.y1} #{@path.x2} #{@path.y2}"} stroke={@path.line_color} stroke-dasharray={if @path.line_dashed, do: @path.line_dash, else: ""}, stroke-width={@path.line_width}, marker-end={if @path.has_marker, do: "url(#markerArrow-#{@path.id}", else: ""}, id={@path.id} />
    </g>
    """
  end
end
