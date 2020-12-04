defmodule MudWeb.CommandController do
  use MudWeb, :controller

  alias Mud.Engine.Command

  action_fallback(MudWeb.FallbackController)

  def index(conn, _params) do
    commands = Command.list()
    render(conn, "index.json", commands: commands)
  end

  def create(conn, command_params) do
    with {:ok, %Command{} = command} <- Command.create(command_params) do
      conn
      |> put_status(:created)
      |> render("show.json", command: command)
    end
  end

  @spec show(Plug.Conn.t(), map) :: Plug.Conn.t()
  def show(conn, %{"id" => id}) do
    command = Command.get!(id)
    render(conn, "show.json", command: command)
  end

  def update(conn, %{"id" => id, "command" => command_params}) do
    command = Command.get!(id)

    with {:ok, %Command{} = command} <- Command.update(command, command_params) do
      render(conn, "show.json", command: command)
    end
  end

  def delete(conn, %{"id" => id}) do
    command = Command.get!(id)

    with {:ok, %Command{}} <- Command.delete(command) do
      send_resp(conn, :no_content, "")
    end
  end
end
