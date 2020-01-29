defmodule MudWeb.Plug.RedirectAnonymousPlayer do
  def init(path \\ nil) do
    path
  end

  def call(conn, path) do
    if not conn.assigns.player_authenticated? do
      if path == nil do
        case List.keyfind(conn.req_headers, "referer", 0) do
          {"referer", referer} ->
            uri = MudWeb.Util.referrer_to_uri(referer)

            Phoenix.Controller.redirect(conn, to: uri)

          nil ->
            Phoenix.Controller.redirect(conn, to: "/")
        end
      else
        Phoenix.Controller.redirect(conn, to: path)
      end
    else
      conn
    end
  end
end
