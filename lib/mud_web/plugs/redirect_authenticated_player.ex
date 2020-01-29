defmodule MudWeb.Plug.RedirectAuthenticatedPlayer do

  def init(path) do
    path
  end

  def call(conn, path) do
    if conn.assigns.player_authenticated? do
      Phoenix.Controller.redirect(conn, to: path)
    else
      conn
    end
  end
end
