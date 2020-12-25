defmodule MudWeb.CharacterChannel do
  use Phoenix.Channel

  alias Mud.Engine

  require Logger

  def join("character:" <> character_id, _message, socket) do
    # TODO: security check her
    # if character.player_id === conn.assigns.player.id do
    Engine.start_character_session(character_id)
    Engine.Session.subscribe(character_id)

    # Send a silent look command
    # Engine.Session.cast_message_or_event(%Engine.Message.Input{
    #   id: UUID.uuid4(),
    #   to: character_id,
    #   text: "look",
    #   type: :silent
    # })

    # conn
    # |> put_session(:character_id, character_id)
    # end

    {:ok, assign(socket, :character_id, character_id)}
  end

  def handle_info({:DOWN, _ref, :process, _pid, _reason}, socket) do
    error_message =
      "{{error}}Something went wrong with the session and the connection has been terminated.{{/error}}"

    Phoenix.Channel.push(socket, "output:story", %{text: error_message})

    {:stop, :normal, socket}
  end

  def handle_in("ping", _input, socket) do
    {:reply, {:ok, %{response: "pong"}}, socket}
  end

  def handle_in("cli", %{"text" => input}, socket) do
    # Mud.Engine.Session.cast_message_or_event(%Mud.Engine.Message.Input{
    #   to: socket.assigns.character_id,
    #   text: input,
    #   id: UUID.uuid4()
    # })

    #  Echo for now
    Phoenix.Channel.push(socket, "output:story", %{text: "> #{input}", type: "echo"})

    {:noreply, socket}
  end

  def handle_cast(%Mud.Engine.Message.Output{} = output, socket) do
    Logger.info("character_channel:#{socket.assigns.character_id}:output")
    IO.inspect(output)
    Phoenix.Channel.push(socket, "output:story", %{text: output.text, type: output.type})

    {:noreply, socket}
  end
end
