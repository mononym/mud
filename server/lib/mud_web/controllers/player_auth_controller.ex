defmodule MudWeb.PlayerAuthController do
  use MudWeb, :controller
  plug(Ueberauth)

  alias Mud.Account
  alias Ueberauth.Strategy.Helpers

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
        |> put_session("player_id", player.id)
        |> put_view(MudWeb.PlayerView)
        |> render("player.json", player: player)

      _error ->
        conn
        |> resp(404, "The provided token was invalid.")
        |> send_resp()
    end
  end

  def sync_status(conn, _) do
    with true <- conn.assigns.player_authenticated?,
         {:ok, player} <- Mud.Account.get_player(conn.assigns.player_id) do
      player =
        Map.from_struct(player)
        |> Map.delete(:profile)
        |> Map.delete(:__meta__)
        |> Map.delete(:auth_email)
        |> Map.delete(:settings)

      conn
      |> put_status(200)
      |> json(%{authenticated: true, player: player})
    else
      {:error, _} ->
        conn
        |> clear_session()
        |> put_status(200)
        |> json(%{authenticated: false})

      _ ->
        conn
        |> put_status(200)
        |> json(%{authenticated: false})
    end
  end

  # Start Auth0 flow
  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  # Failure Auth0
  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  # Success Auth0
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case Account.from_auth(auth.extra.raw_info.user) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Successfully authenticated.")
        |> put_session(:current_user, user)
        |> configure_session(renew: true)
        |> redirect(to: "/")

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end
end
