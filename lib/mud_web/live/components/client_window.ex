defmodule MudWeb.Live.Component.ClientWindow do
  use Phoenix.LiveComponent

  def mount(socket) do
    {:ok,
     assign(socket,
       active_pane: nil,
       initialized: false,
       panes: []
     )}
  end

  def update(assigns, socket) do
    socket =
      if not socket.assigns.initialized do
        assign(socket,
          active_pane: (assigns[:panes] || socket.assigns[:panes]) |> List.first(),
          initialized: true,
          panes: assigns.panes,
          id: assigns.id,
          character: assigns.character
        )
      else
        socket
      end

    {:ok, socket}
  end

  def render(assigns) do
    Phoenix.View.render(MudWeb.MudClientView, "client_window.html", assigns)
  end

  def handle_event("select_pane", %{"pane" => pane}, socket) do
    {:noreply,
     assign(socket,
       active_pane: pane
     )}
  end

  # def handle_event("expand_all", _, socket) do
  #   skillsets_expanded =
  #     Enum.into(socket.assigns.skillsets_expanded, %{}, fn {key, _value} ->
  #       {key, true}
  #     end)

  #   {:noreply,
  #    assign(socket,
  #      skillsets_expanded: skillsets_expanded
  #    )}
  # end

  # def handle_event("collapse_all", _, socket) do
  #   skillsets_expanded =
  #     Enum.into(socket.assigns.skillsets_expanded, %{}, fn {key, _value} ->
  #       {key, false}
  #     end)

  #   {:noreply,
  #    assign(socket,
  #      skillsets_expanded: skillsets_expanded
  #    )}
  # end
end
