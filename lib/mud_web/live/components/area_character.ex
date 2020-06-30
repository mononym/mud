defmodule MudWeb.Live.Component.AreaCharacter do
  use Phoenix.LiveComponent

  def mount(socket) do
    {:ok,
     assign(socket,
       expanded: false
     )}
  end

  def render(assigns) do
    Phoenix.View.render(MudWeb.MudClientView, "area_character.html", assigns)
  end

  def handle_event("toggle_expanded", _, socket) do
    {:noreply,
     assign(socket,
       expanded: not socket.assigns.expanded
     )}
  end

  def handle_event("send", %{"command" => command}, socket) do
    %Mud.Engine.Message.Input{
      id: UUID.uuid4(),
      to: socket.assigns.character_id,
      text: command,
      type: :silent
    }
    |> Mud.Engine.Session.cast_message_or_event()

    {:noreply, socket}
  end
end
