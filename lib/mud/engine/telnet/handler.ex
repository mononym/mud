defmodule Mud.Engine.Telnet.Handler do
  use GenServer, restart: :transient

  import Ecto.Query, warn: false
  require Logger

  #
  #
  # Callbacks
  #
  #

  @doc false
  def start_link(socket) do
    Logger.debug("starting link")
    Logger.debug(inspect(socket))
    GenServer.start_link(__MODULE__, socket)
  end

  @doc false
  @impl true
  def init(socket) do
    Logger.debug("init")
    {:ok, socket, {:continue, :serve}}
  end

  @impl true
  def handle_info({:DOWN, ref, :process, object, _reason}, state = %{ref: ref, session: object}) do
    :gen_tcp.send(state.socket, "Session process died unexpectedly. Apologies.")

    {:stop, :normal, :ok}
  end

  @impl true
  def handle_continue(:serve, socket) do
    spec = {Mud.Engine.Telnet.Session, socket}

    {:ok, session} = DynamicSupervisor.start_child(Mud.Engine.TelnetSupervisor, spec)

    ref = Process.monitor(session)

    serve(%{ref: ref, session: session, socket: socket, buffer: nil})
  end

  defp serve(state) do
    state.socket
    |> read_data()
    |> send_data(state.session)

    serve(state)
  end

  defp read_data(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)

    Logger.debug("received data on socket: #{inspect(data)}")
    String.trim(data)
  end

  defp send_data(data, session) do
    Mud.Engine.Telnet.Session.send_client_input(data, session)
  end
end
