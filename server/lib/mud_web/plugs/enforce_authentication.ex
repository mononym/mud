defmodule MudWeb.Plug.EnforceAuthentication do
  import Plug.Conn

  def init(_params) do
  end

  def call(conn, _) do
    if not conn.assigns.player_authenticated? do
      conn
      |> send_resp(401, "Not authenticated")
      |> halt()
    else
      conn
    end
  end
end
