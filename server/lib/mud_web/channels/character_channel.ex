defmodule MudWeb.CharacterChannel do
  use Phoenix.Channel

  require Logger

  def join("character:" <> character_id, _message, socket) do
    Mud.Engine.Session.subscribe(socket.assigns.character_id)

    {:ok, assign(socket, :character_id, character_id)}
  end

  def handle_info({:DOWN, _ref, :process, _pid, _reason}, socket) do
    error_message =
      "{{error}}Something went wrong with the session and the connection has been terminated.{{/error}}"
      |> Mud.Engine.Message.Output.transform_for_web()

    Phoenix.Channel.push(socket, "output:story", %{text: error_message})

    {:stop, :normal, socket}
  end

  # def handle_in("input", input, socket) do
  #   Mud.Engine.Session.cast_message_or_event(%Mud.Engine.Message.Input{
  #     to: socket.assigns.character_id,
  #     text: input,
  #     id: UUID.uuid4()
  #   })

  #   {:noreply, socket}
  # end

  def handle_cast(%Mud.Engine.Message.Output{} = output, socket) do
    Phoenix.Channel.push(socket, "output:story", %{text: output.text})

    {:noreply, socket}
  end
end