defmodule Mud.Engine.Session do
  use GenStateMachine

  def start_link(args) do
    GenStateMachine.start_link(__MODULE__, args,
      name: {:via, Registry, {Mud.Engine.CharacterSessionRegistry, args[:character_id]}}
    )
  end

  def init(character_id: character_id) do
    :ok = Phoenix.PubSub.subscribe(Mud.PubSub, "session:#{character_id}")

    {:ok, :idle, %{character_id: character_id, message_counter: 1}}
  end

  def handle_event(_type, {:input, input}, :idle, state) do
    Phoenix.PubSub.broadcast_from!(
      Mud.PubSub,
      self(),
      "session:#{state.character_id}",
      {:echo, input, state.message_counter}
    )

    # process command
    {:next_state, :idle, %{state | message_counter: state.message_counter + 1}}
  end

  # def handle_event(:output, :idle, :on, data) do
  #   {:next_state, :off, data}
  # end

  # def handle_event({:call, from}, :get_count, state, data) do
  #   {:next_state, state, data, [{:reply, from, data}]}
  # end
end
