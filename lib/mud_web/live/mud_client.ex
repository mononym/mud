defmodule MudWeb.MudClientLive do
  use Phoenix.LiveView

  def mount(_params, session, socket) do
    :ok = Mud.Engine.start_character_session(session["character_id"])
    :ok = Mud.Engine.subscribe_to_character_output_messages(session["character_id"])

    {:ok,
     assign(socket, %{
       player_id: session["player"].id,
       character_id: session["character_id"],
       command: "",
       even: true,
       messages: []
     }), temporary_assigns: [messages: []]}
  end

  def render(assigns) do
    assigns = %{assigns | command: ""}
    MudWeb.MudClientView.render("v1.html", assigns)
  end

  def handle_event("input", %{"code" => "Enter", "value" => input}, socket) do
    Mud.Engine.send_message_as_character_input(%Mud.Engine.InputMessage{
      character_id: socket.assigns.character_id,
      player_id: socket.assigns.player_id,
      text: input
    })

    {:noreply,
     assign(socket, %{
       even: !socket.assigns.even
     })}
  end

  def handle_event("input", _, socket) do
    {:noreply, socket}
  end

  def handle_info({:output, message}, socket) do
    {:noreply,
     assign(socket, %{
       messages: socket.assigns.messages ++ [%{id: UUID.uuid4(), text: message.text}]
     })}
  end
end
