defmodule Mud.Engine.Telnet.Acceptor do
  require Logger

  @doc """
  Starts accepting connections on the given `port`.
  """
  def accept(port \\ 56412) do
    {:ok, socket} =
      :gen_tcp.listen(
        port,
        [:binary, packet: :raw, active: false, reuseaddr: true, nodelay: true]
      )

    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)

    spec = {Mud.Engine.Telnet.Handler, client}

    {:ok, child} = DynamicSupervisor.start_child(Mud.Engine.TelnetSupervisor, spec)

    :ok = :gen_tcp.controlling_process(client, child)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    socket
    |> read_line()
    |> write_line(socket)

    serve(socket)
  end

  defp read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end
end
