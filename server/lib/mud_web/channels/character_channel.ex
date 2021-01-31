defmodule MudWeb.CharacterChannel do
  use Phoenix.Channel

  alias Mud.Engine

  require Logger

  def join("character:" <> character_id, _message, socket) do
    # TODO: security check here
    # if character.player_id === conn.assigns.player.id do
    Engine.start_character_session(character_id)
    Engine.Session.subscribe(character_id)

    # Send a silent look command
    Engine.Session.cast_message_or_event(%Engine.Message.Input{
      id: UUID.uuid4(),
      to: character_id,
      text: "look",
      type: :silent
    })

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
    Logger.debug("Received cli input: #{input}")

    Mud.Engine.Session.cast_message_or_event(%Mud.Engine.Message.Input{
      to: socket.assigns.character_id,
      text: input,
      id: UUID.uuid4()
    })

    #  Echo for now
    # Phoenix.Channel.push(socket, "output:story", %{
    #   messages: [%{text: "> #{input}", type: "echo"}]
    # })

    {:noreply, socket}
  end

  def handle_cast({:story_output, output}, socket) do
    Logger.info("character_channel:#{socket.assigns.character_id}:output")
    Logger.debug("story_output: #{inspect(output)}")

    Phoenix.Channel.push(socket, "output:story", %{messages: output})

    {:noreply, socket}
  end

  def handle_cast({:update_inventory, updated_items}, socket) do
    Logger.info("character_channel:#{socket.assigns.character_id}:update")
    Logger.debug("update_inventory: #{inspect(updated_items)}")

    Phoenix.Channel.push(socket, "update:inventory", updated_items)

    {:noreply, socket}
  end

  def handle_cast({:update_character, character}, socket) do
    Logger.info("character_channel:#{socket.assigns.character_id}:update")
    Logger.debug("update_character: #{inspect(character)}")

    Phoenix.Channel.push(socket, "update:character", %{
      character: Phoenix.View.render_one(character, MudWeb.CharacterView, "character.json")
    })

    {:noreply, socket}
  end

  def handle_cast({:update_area, updated_data}, socket) do
    Logger.info("character_channel:#{socket.assigns.character_id}:update_area")
    Logger.debug("update_area: #{inspect(updated_data)}")

    Phoenix.Channel.push(socket, "update:area", updated_data)

    {:noreply, socket}
  end

  def handle_cast({:update_explored_area, updated_data}, socket) do
    Logger.info("character_channel:#{socket.assigns.character_id}:update_explored_area")
    Logger.debug("update_explored_area: #{inspect(updated_data)}")

    Phoenix.Channel.push(socket, "update:explored_areas", updated_data)

    {:noreply, socket}
  end

  @doc """
  If the reason is `{:shutdown, :left}` the client UI was used to end the game session nicely.
  """
  def terminate({:shutdown, :left}, socket) do
    # Send a quit command before letting the process continue to shut down
    Engine.Session.cast_message_or_event(%Engine.Message.Input{
      id: UUID.uuid4(),
      to: socket.assigns.character_id,
      text: "quit"
    })

    :ok
  end

  def terminate(_, _) do
    :ok
  end
end
