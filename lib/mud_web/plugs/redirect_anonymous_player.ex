defmodule MudWeb.Plug.RedirectAnonymousPlayer do

  def init(path) do
    path
  end

  def call(conn, path) do
    if not conn.assigns.player_authenticated? do
      Phoenix.Controller.redirect(conn, to: path)
    else
      conn
    end
  end
end
