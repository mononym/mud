defmodule MudWeb.MudClientLive do
  use Phoenix.LiveView

  alias Mud.Engine.{Character, Item}
  alias Mud.Engine.Event
  alias Mud.Engine.Event.Client.{UpdateArea, UpdateInventory, UpdateCharacter}
  alias MudWeb.Live.Component.{AreaOverview, CharacterInventory}
  alias Mud.Engine.Character.ClientState

  require Logger

  defmodule Input do
    use Ecto.Schema

    embedded_schema do
      field(:content, :string, default: "")
    end

    def new, do: %__MODULE__{} |> Ecto.Changeset.change(%{id: UUID.uuid4()})

    def new(content),
      do: %__MODULE__{} |> Ecto.Changeset.change(%{id: UUID.uuid4(), content: content})
  end

  def mount(_params, session, socket) do
    Mud.Engine.Session.subscribe(session["character_id"])

    {:ok,
     assign(socket,
       character: Character.get_by_id!(session["character_id"]),
       input: Input.new(),
       messages: [],
       commands: [],
       command_index: 0,
       viewing_history: false,
       latest_input: "",
       top_left: ["area"],
       bottom_left: ["inventory"],
       top_right: ["map"],
       bottom_right: ["skills"],
       client_state:
         ClientState.load_or_create(session["character_id"])
         |> Ecto.Changeset.change()
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

  def handle_event("move_pane", pane, socket) do
    [from_str, pane, to_str] = String.split(pane, ":")
    from = String.to_existing_atom(from_str)
    to = String.to_existing_atom(to_str)

    socket =
      socket
      |> assign(from, Enum.filter(socket.assigns[from], &(&1 != pane)))
      |> assign(to, [pane | socket.assigns[to]])

    {:noreply, socket}
  end

  def handle_event("input_change", %{"input" => %{"content" => input}}, socket) do
    Logger.debug(inspect(input))
    {:noreply, assign(socket, :latest_input, input)}
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

    {:noreply,
     assign(socket,
       input: Input.new(),
       commands: Enum.slice([input | socket.assigns.commands], 0..99),
       command_index: 0,
       viewing_history: false,
       latest_input: ""
     )}
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

    {:noreply, process_hotkey(event, socket)}
  end

  def handle_info({:update_client_state, key, value}, socket) do
    state = ClientState.modify(socket.assigns.client_state, key, value)

    {:noreply, assign(socket, :client_state, state)}
  end

  def terminate(_, socket) do
    ClientState.update!(socket.assigns.client_state)
  end

  def handle_cast(%Event{event: event = %UpdateCharacter{}}, socket) do
    IO.puts("HANDLE BROADCAST FOR UPDATE CHARACTER")

    send_update(Map, id: socket.assigns.character.id, character: event.character)

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

  defp process_hotkey(%{"code" => "Numpad9", "ctrlKey" => true}, socket) do
    send_command(socket.assigns.character.id, "northeast")

    socket
  end

  defp process_hotkey(%{"code" => "Numpad8", "ctrlKey" => true}, socket) do
    send_command(socket.assigns.character.id, "north")

    socket
  end

  defp process_hotkey(%{"code" => "Numpad7", "ctrlKey" => true}, socket) do
    send_command(socket.assigns.character.id, "northwest")

    socket
  end

  defp process_hotkey(%{"code" => "Numpad6", "ctrlKey" => true}, socket) do
    send_command(socket.assigns.character.id, "east")

    socket
  end

  defp process_hotkey(%{"code" => "Numpad5", "ctrlKey" => true}, socket) do
    send_command(socket.assigns.character.id, "out")

    socket
  end

  defp process_hotkey(%{"code" => "Numpad5", "altKey" => true}, socket) do
    send_command(socket.assigns.character.id, "in")

    socket
  end

  defp process_hotkey(%{"code" => "Numpad4", "ctrlKey" => true}, socket) do
    send_command(socket.assigns.character.id, "west")

    socket
  end

  defp process_hotkey(%{"code" => "Numpad3", "ctrlKey" => true}, socket) do
    send_command(socket.assigns.character.id, "southeast")

    socket
  end

  defp process_hotkey(%{"code" => "Numpad2", "ctrlKey" => true}, socket) do
    send_command(socket.assigns.character.id, "south")

    socket
  end

  defp process_hotkey(%{"code" => "Numpad1", "ctrlKey" => true}, socket) do
    send_command(socket.assigns.character.id, "southwest")

    socket
  end

  defp process_hotkey(%{"code" => "ArrowUp"}, socket) do
    cond do
      Enum.empty?(socket.assigns.commands) ->
        socket

      socket.assigns.viewing_history ->
        new_index = min(socket.assigns.command_index + 1, length(socket.assigns.commands) - 1)

        socket
        |> assign(
          :command_index,
          new_index
        )
        |> assign(
          :input,
          Input.new(
            Enum.at(
              socket.assigns.commands,
              new_index
            )
          )
        )

      true ->
        socket
        |> assign(:viewing_history, true)
        |> assign(:input, Input.new(List.first(socket.assigns.commands)))
    end
  end

  defp process_hotkey(%{"code" => "ArrowDown"}, socket) do
    cond do
      socket.assigns.viewing_history and socket.assigns.command_index == 0 ->
        socket
        |> assign(:viewing_history, false)
        |> assign(:input, Input.new(socket.assigns.latest_input))

      socket.assigns.viewing_history ->
        new_index = socket.assigns.command_index - 1

        socket
        |> assign(
          :command_index,
          new_index
        )
        |> assign(:input, Input.new(Enum.at(socket.assigns.commands, new_index)))

      true ->
        socket
    end
  end

  defp process_hotkey(_, assigns) do
    assigns
  end

  defp send_command(character_id, text, type \\ :normal) do
    %Mud.Engine.Message.Input{id: UUID.uuid4(), to: character_id, text: text, type: type}
    |> Mud.Engine.Session.cast_message_or_event()
  end
end
