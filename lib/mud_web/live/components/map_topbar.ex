defmodule MudWeb.Live.Component.MapTopbar do
  use Phoenix.LiveComponent

  def render(assigns) do
    Phoenix.View.render(MudWeb.MudClientMapView, "topbar.html", assigns)
  end
end
