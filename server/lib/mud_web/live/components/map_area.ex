defmodule MudWeb.Live.Component.MapArea do
  use Phoenix.LiveComponent

  def render(assigns) do
    Phoenix.View.render(MudWeb.MudClientMapView, "area.html", assigns)
  end
end
