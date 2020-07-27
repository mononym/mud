defmodule Mud.Engine.Telnet.Session do
  use GenStateMachine

  alias Mud.Account
  alias Mud.Engine.GMCP

  require Logger

  defmodule State do
    use TypedStruct

    typedstruct do
      field(:buffer, binary(), default: <<>>)
      field(:socket, term())
      field(:player, Mud.Account.Player.t())
    end
  end

  #
  # API
  #

  def start_link(socket) do
    GenStateMachine.start_link(__MODULE__, %State{socket: socket})
  end

  def send_client_input(input, session) do
    Logger.debug("Sending input to session: #{inspect(input)}")
    GenStateMachine.call(session, {:client_input, input})
  end

  #
  # Callbacks
  #

  def init(state) do
    {:ok, :gmcp_handshake, state, [{:next_event, :internal, :start_handshake}]}
  end

  def handle_event(:internal, :start_handshake, :gmcp_handshake, state) do
    Logger.debug("Sending GMCP handshake message to client")
    :gen_tcp.send(state.socket, GMCP.start_handshake_message())

    {:next_state, :gmcp_handshake, state}
  end

  def handle_event({:call, from}, {:client_input, gmcp_response}, :gmcp_handshake, state) do
    Logger.debug("Client GMCP response: #{inspect(gmcp_response)}")

    case Mud.Engine.GMCP.client_accepts_gmcp(gmcp_response) do
      {:ok, buffer} ->
        Logger.debug("Client accepts GMCP")

        {:next_state, :process_greeting, %{state | buffer: buffer},
         [{:next_event, :internal, :process}, {:reply, from, :ok}]}

      {:error, _buffer} ->
        Logger.debug("Client cannot handle GMCP")
        {:stop_and_reply, :normal, [{:reply, from, :ok}]}
    end
  end

  def handle_event(:internal, :process, :process_greeting, state) do
    state = process_buffer(state)

    {:next_state, :awaiting_email, state, [{:next_event, :internal, :prompt_for_email}]}
  end

  def handle_event(:internal, :prompt_for_email, :awaiting_email, state) do
    :gen_tcp.send(state.socket, "Please enter your email address to sign up or log in.\r\n")

    {:next_state, :awaiting_email, state}
  end

  def handle_event({:call, from}, {:client_input, email}, :awaiting_email, state) do
    case Account.authenticate_via_email(email) do
      {:ok, _} ->
        :gen_tcp.send(
          state.socket,
          "Please check provided email address for a message from us!\r\n"
        )

        {:next_state, :awaiting_otp, state, [{:reply, from, :ok}]}

      {:error, _} ->
        :gen_tcp.send(
          state.socket,
          "Something went wrong. Please try again. If error persists please contact support.\r\n"
        )

        {:next_state, :awaiting_email, state, [{:reply, from, :ok}]}
    end
  end

  def handle_event({:call, from}, {:client_input, token}, :awaiting_otp, state) do
    case Account.validate_auth_token(token) do
      {:ok, player} ->
        :gen_tcp.send(
          state.socket,
          "Authentication successful!\r\n"
        )

        {:next_state, :echoing, %{state | player: player}, [{:reply, from, :ok}]}

      _error ->
        :gen_tcp.send(
          state.socket,
          "The provided token was invalid. Either it has already been used or it has expired.\r\n"
        )

        {:next_state, :awaiting_otp, state, [{:reply, from, :ok}]}
    end
  end

  def handle_event({:call, from}, {:client_input, input}, :echoing, state) do
    :gen_tcp.send(state.socket, "#{input}\r\n")

    {:repeat_state_and_data, [{:reply, from, :ok}]}
  end

  #
  # Private functions
  #

  defp process_buffer(state = %{buffer: ""}) do
    state
  end

  defp process_buffer(state) do
    cond do
      GMCP.binary_starts_with_complete_gmcp_message?(state.buffer) ->
        {message, buffer} = GMCP.parse_gmcp_message(state.buffer)

        state = %{state | buffer: buffer}

        state = process_message(message, state)

        process_buffer(state)

      starts_with_complete_input_message(state.buffer) ->
        {message, buffer} = parse_input_message(state.buffer)

        %{state | buffer: buffer}

        state = process_message(message, state)

        process_buffer(state)

      true ->
        state
    end
  end

  defp starts_with_complete_input_message(buffer) do
    case :binary.match(buffer, [<<"\r", "\n">>]) do
      :nomatch ->
        false

      {0, 3} ->
        true
    end
  end

  defp parse_input_message(buffer) do
    [message, bin] = :binary.split(buffer, <<"\r", "\n">>)
    Logger.debug("parsed input message: #{inspect(message)}")

    {message, bin}
  end

  defp process_message(message, state) do
    Logger.debug("process_message: #{inspect(message)}")
    state
  end
end
