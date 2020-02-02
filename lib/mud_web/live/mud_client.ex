defmodule MudWeb.MudClientLive do
  use Phoenix.LiveView

  require Logger

  def mount(_params, session, socket) do
    {:ok,
     assign(socket, %{
       character_id: session["character_id"]
     })}
  end

  def render(assigns) do
    MudWeb.MudClientView.render("v1.html", assigns)
  end

  def handle_event("hotkey", event, socket) do
    process_hotkey(socket.assigns.character_id, event)

    {:noreply, socket}
  end

  defp process_hotkey(character_id, %{"code" => "Numpad9", "ctrlKey" => true}) do
    send_hotkey(character_id, "northeast")
  end

  defp process_hotkey(character_id, %{"code" => "Numpad8", "ctrlKey" => true}) do
    send_hotkey(character_id, "north")
  end

  defp process_hotkey(character_id, %{"code" => "Numpad7", "ctrlKey" => true}) do
    send_hotkey(character_id, "northwest")
  end

  defp process_hotkey(character_id, %{"code" => "Numpad6", "ctrlKey" => true}) do
    send_hotkey(character_id, "east")
  end

  defp process_hotkey(character_id, %{"code" => "Numpad5", "ctrlKey" => true}) do
    send_hotkey(character_id, "out")
  end

  defp process_hotkey(character_id, %{"code" => "Numpad5", "altKey" => true}) do
    send_hotkey(character_id, "in")
  end

  defp process_hotkey(character_id, %{"code" => "Numpad4", "ctrlKey" => true}) do
    send_hotkey(character_id, "west")
  end

  defp process_hotkey(character_id, %{"code" => "Numpad3", "ctrlKey" => true}) do
    send_hotkey(character_id, "southeast")
  end

  defp process_hotkey(character_id, %{"code" => "Numpad2", "ctrlKey" => true}) do
    send_hotkey(character_id, "south")
  end

  defp process_hotkey(character_id, %{"code" => "Numpad1", "ctrlKey" => true}) do
    send_hotkey(character_id, "southwest")
  end

  defp process_hotkey(_, _) do
    :ok
  end

  defp send_hotkey(character_id, text) do
    %Mud.Engine.Input{id: UUID.uuid4(), character_id: character_id, text: text}
    |> Mud.Engine.cast_message_to_character_session()
  end
end
