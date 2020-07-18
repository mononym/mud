defmodule MudWeb.Live.Component.ClientWindow do
  use Phoenix.LiveComponent

  def mount(socket) do
    {:ok,
     assign(socket,
       active_pane: nil,
       panes: [],
       client_state: nil
     )}
  end

  def update(assigns, socket) do
    IO.inspect({assigns, socket.assigns}, label: :window_update)

    {:ok,
     assign(socket,
       active_pane: (assigns[:panes] || socket.assigns[:panes]) |> List.first(),
       panes: assigns.panes,
       id: assigns.id,
       character: assigns[:character] || socket.assigns.character,
       client_state: assigns[:client_state]
     )
     |> IO.inspect()}
  end

  def render(assigns) do
    Phoenix.View.render(MudWeb.MudClientView, "client_window.html", assigns)
  end

  def handle_event("select_pane", %{"pane" => pane}, socket) do
    {:noreply,
     assign(socket,
       active_pane: pane
     )
     |> IO.inspect()}
  end
end
