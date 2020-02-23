defmodule MudWeb.CharacterChannel do
  use Phoenix.Channel

  require Logger

  def join("character:" <> character_id, _message, socket) do
    Logger.debug("#{inspect(character_id)}")
    send(self(), :after_join)

    {:ok, assign(socket, :character_id, character_id)}
  end

  def handle_info(:after_join, socket) do
    Logger.debug("#{inspect(:after_join)}")
    Mud.Engine.Session.subscribe(socket.assigns.character_id)

    {:noreply, socket}
  end

  def handle_info({:DOWN, _ref, :process, _pid, _reason} = message, socket) do
    Logger.debug("#{inspect(message)}")

    error_message =
      "{{error}}Something went wrong with the session and the connection has been terminated.{{/error}}"
      |> Mud.Engine.Output.transform_for_web()

    Phoenix.Channel.push(socket, "output:story", %{text: error_message})

    {:stop, :normal, socket}
  end

  def handle_in("autocomplete", input, socket) do
    Logger.debug(input, label: "character_channel autocomplete")

    Mud.Engine.cast_message_to_character_session(%Mud.Engine.Input{
      character_id: socket.assigns.character_id,
      text: input,
      id: UUID.uuid4(),
      type: :autocomplete
    })

    {:noreply, socket}
  end

  def handle_in("input", input, socket) do
    Logger.debug(input, label: "character_channel input")

    Mud.Engine.cast_message_to_character_session(%Mud.Engine.Input{
      character_id: socket.assigns.character_id,
      text: input,
      id: UUID.uuid4()
    })

    {:noreply, socket}
  end

  def handle_cast(%Mud.Engine.Output{} = output, socket) do
    Logger.debug("#{inspect(output)}")

    Phoenix.Channel.push(socket, "output:story", %{text: output.text})

    {:noreply, socket}
  end
end
