defmodule MudWeb.MapLive.RectComponent do
  use MudWeb, :live_component

  def render(assigns) do
    ~H"""
    <rect x={@rect.x} y={@rect.y} width={@rect.width} height={@rect.height}, rx={@rect.corners}, fill={@rect.fill}, stroke-width={@rect.border_width} stroke={@rect.border_color} class={@rect.cursor} id={@rect.id}>
      <title><%= @rect.name %></title>
    </rect>
    """
  end
end
