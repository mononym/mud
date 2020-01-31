defmodule Mud.Engine.Session do
  use GenStateMachine

  def start_link(args) do
    GenStateMachine.start_link(__MODULE__, args,
      name: {:via, Registry, {Mud.Engine.CharacterSessionRegistry, args[:character_id]}}
    )
  end

  def init(character_id: character_id) do
    character_id
    |> Mud.Engine.get_character!()
    |> Mud.Engine.update_character(%{active: true})

    :ok = Mud.Engine.subscribe_to_character_input_messages(character_id)

    {:ok, :idle, %{character_id: character_id}}
  end

  def handle_event(_type, {:input, message}, :idle, state) do
    Mud.Engine.send_message_for(
      Mud.Engine.Message.new(
        message.character_id,
        "{{echo}}> #{message.text}{{/echo}}",
        :output
      )
    )

    Mud.Engine.Input.process(message.player_id, message.character_id, message.text)

    {:keep_state, state}
  end

  def handle_event(_type, {:silent_input, message}, :idle, state) do
    Mud.Engine.Input.process(message.player_id, message.character_id, message.text)

    {:keep_state, state}
  end

  def terminate(_reason, _state, %{character_id: character_id}) do
    character_id
    |> Mud.Engine.get_character!()
    |> Mud.Engine.update_character(%{active: false})
  end
end
