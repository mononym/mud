defmodule MudWeb.Plug.RejectAuthenticatedUser do
  import Plug.Conn

  def init(_params) do
  end

  def call(conn, _params) do
    if conn.assigns.player_authenticated? do
      conn
      |> put_status(401)
      |> Phoenix.Controller.put_view(MudWeb.ErrorView)
      |> Phoenix.Controller.render("401.json")
      |> halt()
    else
      conn
    end
  end
end
