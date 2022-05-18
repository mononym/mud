defmodule MudWeb.Plug.EnforceAuthentication do
  import Plug.Conn

  def init(_params) do
  end

  def call(conn, _) do
    if Map.get(conn.assigns, :current_player, false) do
      conn
      |> send_resp(401, "Not authenticated")
      |> halt()
    else
      conn
    end
  end
end
