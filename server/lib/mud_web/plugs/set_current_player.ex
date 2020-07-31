defmodule MudWeb.Plug.SetPlayer do
  import Plug.Conn

  def init(_params) do
  end

  def call(conn, _params) do
    case Plug.Conn.get_session(conn, "player") do
      player = %Mud.Account.Player{} ->
        conn
        |> assign(:player, player)
        |> assign(:player_authenticated?, true)

      nil ->
        conn
        |> assign(:player, nil)
        |> assign(:player_authenticated?, false)
    end
  end
end
