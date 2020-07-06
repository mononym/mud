defmodule MudWeb.MudClientLive do
  use Phoenix.LiveView

  alias Mud.Engine.{Character, Item}
  alias Mud.Engine.Event
  alias Mud.Engine.Event.Client.{UpdateArea, UpdateInventory, UpdateCharacter}
  alias MudWeb.Live.Component.{AreaOverview, CharacterInventory}

  require Logger

  defmodule Input do
    use Ecto.Schema

    embedded_schema do
      field(:content, :string, default: "")
    end

    def new, do: %__MODULE__{id: UUID.uuid4()} |> Ecto.Changeset.change()
  end

  def mount(_params, session, socket) do
    Mud.Engine.Session.subscribe(session["character_id"])

    {:ok,
     assign(socket,
       character: Character.get_by_id!(session["character_id"]),
       input: Input.new(),
       messages: []
     ), temporary_assigns: [messages: []]}
  end

  def render(assigns) do
    Logger.debug(inspect(assigns))
    MudWeb.MudClientView.render("v1.html", assigns)
  end

  def handle_event("set_primary_container", %{"id" => item_id}, socket) do
    case Item.get_primary_container(socket.assigns.character.id) do
      nil ->
        item = Item.update!(item_id, %{container_primary: true})

        send_update(CharacterInventory,
          id: socket.assigns.character.id,
          event: UpdateInventory.new(:update, item)
        )

      primary_container ->
        primary_container = Item.update!(primary_container.id, %{container_primary: false})
        item = Item.update!(socket.assigns.id, %{container_primary: true})

        send_update(CharacterInventory,
          id: socket.assigns.character.id,
          event: UpdateInventory.new(:update, [primary_container, item])
        )
    end

    {:noreply, socket}
  end

  def handle_event("submit_input", %{"input" => %{"content" => ""}}, socket) do
    Logger.debug(inspect(socket.assigns.input))
    {:noreply, socket}
  end

  # input sent via text box
  def handle_event("submit_input", %{"input" => %{"content" => input}}, socket) do
    Logger.debug("Handling input event: #{inspect(input)}")
    send_command(socket.assigns.character.id, input)
    Logger.debug("Sent input")

    {:noreply, assign(socket, input: Input.new())}
  end

  # input sent from button clicks and the like
  def handle_event("send", %{"command" => command}, socket) do
    send_command(socket.assigns.character.id, command, :silent)

    {:noreply, socket}
  end

  def handle_event("typing", _value, socket) do
    Logger.debug("started typing")
    {:noreply, socket}
  end

  def handle_event(
        "stop_typing",
        _value,
        socket
      ) do
    Logger.debug("stopped typing")
    {:noreply, socket}
  end

  def handle_event("hotkey", event, socket) do
    Logger.debug("hotkey event received: #{inspect(event)}")

    assigns = process_hotkey(event, socket.assigns)

    {:noreply, %{socket | assigns: assigns}}
  end

  def handle_cast(%Event{event: event = %UpdateCharacter{}}, socket) do
    IO.puts("HANDLE BROADCAST FOR UPDATE CHARACTER")

    send_update(Map, id: socket.assigns.character.id, area_id: socket.assigns.character.area_id)

    {:noreply, assign(socket, :character, event.character)}
  end

  def handle_cast(%Event{event: event = %UpdateInventory{}}, socket) do
    IO.puts("HANDLE BROADCAST FOR UPDATE INVENTORY")

    send_update(CharacterInventory, id: socket.assigns.character.id, event: event)

    {:noreply, socket}
  end

  def handle_cast(%Event{event: event = %UpdateArea{}}, socket) do
    IO.puts("HANDLE BROADCAST FOR UPDATE AREA")

    send_update(AreaOverview, id: socket.assigns.character.area_id, event: event)

    {:noreply, socket}
  end

  def handle_cast(%Mud.Engine.Message.Output{} = output, socket) do
    Logger.debug("Received output : #{inspect(output)}")

    {:noreply, assign(socket, messages: [output.text | socket.assigns.messages])}
  end

  def handle_cast(event, socket) do
    IO.inspect(event)

    {:noreply, socket}
  end

  defp process_hotkey(%{"code" => "Numpad9", "ctrlKey" => true}, assigns) do
    send_command(assigns.character.id, "northeast")

    assigns
  end

  defp process_hotkey(%{"code" => "Numpad8", "ctrlKey" => true}, assigns) do
    send_command(assigns.character.id, "north")

    assigns
  end

  defp process_hotkey(%{"code" => "Numpad7", "ctrlKey" => true}, assigns) do
    send_command(assigns.character.id, "northwest")

    assigns
  end

  defp process_hotkey(%{"code" => "Numpad6", "ctrlKey" => true}, assigns) do
    send_command(assigns.character.id, "east")

    assigns
  end

  defp process_hotkey(%{"code" => "Numpad5", "ctrlKey" => true}, assigns) do
    send_command(assigns.character.id, "out")

    assigns
  end

  defp process_hotkey(%{"code" => "Numpad5", "altKey" => true}, assigns) do
    send_command(assigns.character.id, "in")

    assigns
  end

  defp process_hotkey(%{"code" => "Numpad4", "ctrlKey" => true}, assigns) do
    send_command(assigns.character.id, "west")

    assigns
  end

  defp process_hotkey(%{"code" => "Numpad3", "ctrlKey" => true}, assigns) do
    send_command(assigns.character.id, "southeast")

    assigns
  end

  defp process_hotkey(%{"code" => "Numpad2", "ctrlKey" => true}, assigns) do
    send_command(assigns.character.id, "south")

    assigns
  end

  defp process_hotkey(%{"code" => "Numpad1", "ctrlKey" => true}, assigns) do
    send_command(assigns.character.id, "southwest")

    assigns
  end

  defp process_hotkey(_, assigns) do
    assigns
  end

  defp send_command(character_id, text, type \\ :normal) do
    %Mud.Engine.Message.Input{id: UUID.uuid4(), to: character_id, text: text, type: type}
    |> Mud.Engine.Session.cast_message_or_event()
  end
end
