defmodule MudWeb.MudClientLive do
  use Phoenix.LiveView

  require Logger

  defmodule Input do
    use Ecto.Schema

    embedded_schema do
      field(:content, :string, default: "")
    end

    def new, do: %__MODULE__{} |> Ecto.Changeset.change(%{content: "", id: UUID.uuid4()})
  end

  def mount(_params, session, socket) do
    send(self(), :post_mount)

    {:ok,
     assign(socket,
       character_id: session["character_id"],
       input: Input.new(),
       messages: []
     ), temporary_assigns: [messages: []]}
  end

  def render(assigns) do
    Logger.debug("Rendering MudClient")
    MudWeb.MudClientView.render("v1.html", assigns)
  end

  def handle_event("submit_input", %{"input" => %{"content" => ""}}, socket) do
    {:noreply, assign(socket, input: Input.new())}
  end

  def handle_event("submit_input", %{"input" => %{"content" => input}}, socket) do
    Logger.debug("Handling input event: #{inspect(input)}")
    send_command(socket.assigns.character_id, input)

    {:noreply, assign(socket, input: Input.new())}
  end

  def handle_event("typing", _value, socket) do
    # Presence.update_presence(self(), topic(chat.id), user.id, %{typing: true})
    {:noreply, socket}
  end

  def handle_event(
        "stop_typing",
        _value,
        socket
      ) do
    # message = Chats.change_message(message, %{content: value})
    # Presence.update_presence(self(), topic(chat.id), user.id, %{typing: false})
    {:noreply, socket}
  end

  # def handle_event("input_update", event, socket) do
  #   Logger.debug("input update event received: #{inspect(event)}")

  #   # assigns = process_hotkey(event, socket.assigns)

  #   {:noreply, socket}
  # end

  def handle_event("hotkey", event, socket) do
    Logger.debug("hotkey event received: #{inspect(event)}")
    Logger.debug("assigns: #{inspect(socket.assigns)}")

    assigns = process_hotkey(event, socket.assigns)

    {:noreply, %{socket | assigns: assigns}}
  end

  def handle_info(:post_mount, socket) do
    Mud.Engine.Session.subscribe(socket.assigns.character_id)

    {:noreply, socket}
  end

  def handle_cast(%Mud.Engine.Output{} = output, socket) do
    Logger.debug("Received output : #{inspect(output)}")

    {:noreply, assign(socket, messages: [output.text | socket.assigns.messages])}
  end

  # defp process_hotkey(%{"code" => "Enter"}, assigns) do
  #   send_command(assigns.character_id, assigns.input)

  #   %{assigns | input: ""}
  # end

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
