defmodule MudWeb.CharacterChannel do
  use Phoenix.Channel

  alias Mud.Engine

  require Logger

  def join("character:" <> character_slug, _message, socket) do
    character = Engine.Character.get_by_slug!(character_slug)

    IO.inspect("JOINING CHARACTER CHANNEL")

    # TODO: security check here
    # if character.player_id === conn.assigns.player.id do
    Engine.start_character_session(character.id)
    Engine.Session.subscribe(character.id)

    # Send a silent look command
    Engine.Session.cast_message_or_event(%Engine.Message.Input{
      id: UUID.uuid4(),
      to: character.id,
      text: "look",
      type: :silent
    })

    # conn
    # |> put_session(:character_id, character_id)
    # end

    {:ok, assign(socket, :character_id, character.id)}
  end

  def handle_info({:DOWN, _ref, :process, _pid, _reason}, socket) do
    error_message =
      "{{error}}Something went wrong with the session and the connection has been terminated.{{/error}}"
      # |> Mud.Engine.Message.Output.transform_for_web()

    Phoenix.Channel.push(socket, "output:story", %{text: error_message})

    {:stop, :normal, socket}
  end

  @spec handle_in(<<_::40>>, any, atom | %{assigns: atom | %{character_id: any}}) ::
          {:noreply, atom | %{assigns: atom | %{character_id: any}}}
  def handle_in("input", input, socket) do
    Mud.Engine.Session.cast_message_or_event(%Mud.Engine.Message.Input{
      to: socket.assigns.character_id,
      text: input,
      id: UUID.uuid4()
    })

    {:noreply, socket}
  end

  def handle_cast(%Mud.Engine.Message.Output{} = output, socket) do
    IO.inspect(output, label: "handle_cast")
    Phoenix.Channel.push(socket, "output:story", %{text: output.text})

    {:noreply, socket}
  end
end
