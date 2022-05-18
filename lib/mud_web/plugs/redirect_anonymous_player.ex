defmodule MudWeb.Plug.RedirectAnonymousPlayer do
  import Plug.Conn

  def init(path \\ nil) do
    path
  end

  def call(conn, path) do
    if not conn.assigns.current_player do
      if path == nil do
        case List.keyfind(conn.req_headers, "referer", 0) do
          {"referer", referer} ->
            uri = MudWeb.Util.referrer_to_uri(referer)

            Phoenix.Controller.redirect(conn, to: uri)
            |> halt()

          nil ->
            Phoenix.Controller.redirect(conn, to: "/")
            |> halt()
        end
      else
        Phoenix.Controller.redirect(conn, to: path)
        |> halt()
      end
    else
      conn
    end
  end
end
