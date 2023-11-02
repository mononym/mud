defmodule MudWeb.HealthController do
  use MudWeb, :controller

  def health_check(conn, _params) do
    conn
    |> resp(200, "ok")
    |> send_resp()
  end
end
