defmodule MudWeb.MudClientLive do
  use Phoenix.LiveView

  def mount(_params, session, socket) do
    :ok = Mud.Engine.start_character_session(session["character_id"])
    :ok = Phoenix.PubSub.subscribe(Mud.PubSub, "session:#{session["character_id"]}")

    {:ok,
     assign(socket, %{
       player_id: session["player"].id,
       character_id: session["character_id"],
       command: "",
       even: true,
       submitting: false,
       messages: [],
       message_counter: 0
     }), temporary_assigns: [messages: []]}
  end

  def render(assigns) do
    assigns = %{assigns | command: ""}
    MudWeb.MudClientView.render("v1.html", assigns)
  end

  def handle_event("input", %{"code" => "Enter", "value" => command}, socket) do
    Phoenix.PubSub.broadcast_from!(
      Mud.PubSub,
      self(),
      "session:#{socket.assigns.character_id}",
      {:ping, command}
    )

    {:noreply,
     assign(socket, %{
       even: !socket.assigns.even,
       submitting: true
     })}
  end

  def handle_event("input", _, socket) do
    {:noreply, socket}
  end

  def handle_info(:pong, socket) do
    {:noreply,
     assign(socket, %{
       submitting: false
     })}
  end

  def handle_info({:echo, echo, counter}, socket) do
    {:noreply,
     assign(socket, %{
       messages: socket.assigns.messages ++ [%{id: counter, text: echo}],
       message_counter: counter
     })}
  end
end
