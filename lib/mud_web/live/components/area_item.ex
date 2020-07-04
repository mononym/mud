defmodule MudWeb.Live.Component.AreaItem do
  use Phoenix.LiveComponent

  def mount(socket) do
    {:ok,
     assign(socket,
       expanded: false
     )}
  end

  def render(assigns) do
    Phoenix.View.render(MudWeb.MudClientView, "area_item.html", assigns)
  end

  def handle_event("toggle_expanded", _, socket) do
    {:noreply,
     assign(socket,
       expanded: not socket.assigns.expanded
     )}
  end
end
