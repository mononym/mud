defmodule MudWeb.MapLive.TextComponent do
  use MudWeb, :live_component

  def render(assigns) do
    ~H"""
    <text x={@label.x} y={@label.y} text-anchor="middle" fill={@label.color} dominant-baseline="central" font-size={@label.font_size} font-family="fantasy, sans-sarif", font-weight={@label.font_weight}, font-style="normal", transform={@label.transform}>
      <%= for {text, index} <- Enum.with_index(@label.text) do %>
        <tspan x={@label.x} y={@label.y} dy={"#{index * @label.font_size}px"}><%= text %></tspan>
      <% end %>
    </text>
    """
  end
end
