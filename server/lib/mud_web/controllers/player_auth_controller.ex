defmodule MudWeb.PlayerAuthController do
  use MudWeb, :controller

  alias Mud.Account

  action_fallback(MudWeb.FallbackController)

  def authenticate_via_email(conn, %{"email" => email}) do
    case Account.authenticate_via_email(email) do
      {:ok, _} ->
        conn
        |> resp(200, "ok")
        |> send_resp()

      {:error, _} ->
        conn
        |> resp(501, "Something went wrong.")
        |> send_resp()
    end
  end

  def logout(conn, _params) do
    conn
    |> clear_session()
    |> resp(200, "ok")
    |> send_resp()
  end

  def validate_auth_token(conn, %{"token" => token}) do
    case Account.validate_auth_token(token) do
      {:ok, player} ->
        conn
        |> put_session("player", player)
        |> put_view(MudWeb.PlayerView)
        |> render("player.json", player: player)

      _error ->
        conn
        |> resp(404, "The provided token was invalid.")
        |> send_resp()
    end
  end

  def sync_status(conn, _) do
    if conn.assigns.player_authenticated? do
      conn
      |> put_status(200)
      |> json(%{authenticated: true, player_id: conn.assigns.player.id})
    else
      conn
      |> put_status(200)
      |> json(%{authenticated: false, player_id: ""})
    end
  end
end
