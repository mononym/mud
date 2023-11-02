defmodule MudWeb.Plug.RedirectAuthenticatedPlayer do
  import Plug.Conn

  def init(path) do
    path
  end

  def call(conn, path) do
    if conn.assigns.current_player do
      Phoenix.Controller.redirect(conn, to: path)
      |> halt()
    else
      conn
    end
  end
end
