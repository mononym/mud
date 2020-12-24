defmodule MudWeb.Plug.SetPlayer do
  import Plug.Conn

  def init(_params) do
  end

  def call(conn, _params) do
    case Plug.Conn.get_session(conn, "player_id") do
      nil ->
        conn
        |> assign(:player_id, nil)
        |> assign(:player_authenticated?, false)

      player_id ->
        conn
        |> assign(:player_id, player_id)
        |> assign(:player_authenticated?, true)
    end
  end
end
