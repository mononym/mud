defmodule MudWeb.CsrfTokenController do
  use MudWeb, :controller

  action_fallback MudWeb.FallbackController

  def get_token(conn, _) do
    conn
    |> resp(200, get_csrf_token())
    |> send_resp()
  end
end
