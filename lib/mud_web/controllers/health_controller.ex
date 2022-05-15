defmodule MudWeb.HealthController do
  use MudWeb, :controller

  action_fallback(MudWeb.FallbackController)

  def health_check(conn, _params) do
    conn
    |> resp(200, "ok")
    |> send_resp()
  end
end
