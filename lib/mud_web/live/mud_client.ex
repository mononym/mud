defmodule MudWeb.MudClientLive do
  use Phoenix.LiveView

  require Logger

  def mount(_params, session, socket) do
    send(self(), :post_mount)

    {:ok,
     assign(socket,
       character_id: session["character_id"],
       command: nil,
       input: "",
       matches: [],
       messages: []
     ), temporary_assigns: [messages: []]}
  end

  def render(assigns) do
    MudWeb.MudClientView.render("v1.html", assigns)
  end

  def handle_event("hotkey", event, socket) do
    assigns = process_hotkey(event, socket.assigns)

    {:noreply, %{socket | assigns: assigns}}
  end

  def handle_info(:post_mount, socket) do
    Mud.Engine.Session.subscribe(socket.assigns.character_id)

    {:noreply, socket}
  end

  def handle_cast(%Mud.Engine.Output{} = output, socket) do

    {:noreply, assign(socket, messages: [output | socket.assigns.messages])}
  end

  defp process_hotkey(%{"code" => "Numpad9", "ctrlKey" => true}, assigns) do
    send_command(assigns.character_id, "northeast")

    assigns
  end

  defp process_hotkey(%{"code" => "Numpad8", "ctrlKey" => true}, assigns) do
    send_command(assigns.character_id, "north")

    assigns
  end

  defp process_hotkey(%{"code" => "Numpad7", "ctrlKey" => true}, assigns) do
    send_command(assigns.character_id, "northwest")

    assigns
  end

  defp process_hotkey(%{"code" => "Numpad6", "ctrlKey" => true}, assigns) do
    send_command(assigns.character_id, "east")

    assigns
  end

  defp process_hotkey(%{"code" => "Numpad5", "ctrlKey" => true}, assigns) do
    send_command(assigns.character_id, "out")

    assigns
  end

  defp process_hotkey(%{"code" => "Numpad5", "altKey" => true}, assigns) do
    send_command(assigns.character_id, "in")

    assigns
  end

  defp process_hotkey(%{"code" => "Numpad4", "ctrlKey" => true}, assigns) do
    send_command(assigns.character_id, "west")

    assigns
  end

  defp process_hotkey(%{"code" => "Numpad3", "ctrlKey" => true}, assigns) do
    send_command(assigns.character_id, "southeast")

    assigns
  end

  defp process_hotkey(%{"code" => "Numpad2", "ctrlKey" => true}, assigns) do
    send_command(assigns.character_id, "south")

    assigns
  end

  defp process_hotkey(%{"code" => "Numpad1", "ctrlKey" => true}, assigns) do
    send_command(assigns.character_id, "southwest")

    assigns
  end

  defp process_hotkey(_, assigns) do
    assigns
  end

  defp send_command(character_id, text) do
    %Mud.Engine.Input{id: UUID.uuid4(), character_id: character_id, text: text}
    |> Mud.Engine.cast_message_to_character_session()
  end
end
