defmodule MudWeb.Live.Component.AreaExit do
  use Phoenix.LiveComponent

  alias Mud.Engine.Command

  def mount(socket) do
    {:ok,
     assign(socket,
       expanded: false
     )}
  end

  # def preload(assigns) do
  #   Enum.map(assigns, fn assign ->
  #     assign
  #     |> Map.put(:item, assign.item_index[assign.id])
  #     |> Map.put(:children, assign.child_index[assign.id])
  #   end)
  # end

  def render(assigns) do
    Phoenix.View.render(MudWeb.MudClientView, "area_exit.html", assigns)
  end

  def handle_event("toggle_expanded", _, socket) do
    {:noreply,
     assign(socket,
       expanded: not socket.assigns.expanded
     )}
  end

  def handle_event("send", %{"command" => command}, socket) do
    send_command(socket.assigns.character_id, command)

    {:noreply,
     assign(socket,
       expanded: not socket.assigns.expanded
     )}
  end

  defp send_command(character_id, text) do
    %Mud.Engine.Message.Input{id: UUID.uuid4(), to: character_id, text: text, type: :silent}
    |> Mud.Engine.Session.cast_message_or_event()
  end
end
