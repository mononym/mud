defmodule MudWeb.PlayerAuthController do
  use MudWeb, :controller
  plug(Ueberauth)

  alias Mud.Account
  alias Mud.Engine.Character

  alias Ueberauth.Strategy.Helpers

  action_fallback(MudWeb.FallbackController)

  def logout(conn, _params) do
    conn
    |> clear_session()
    |> resp(200, "ok")
    |> send_resp()
  end

  def authenticate_client(conn, params) do
    token = params["token"]

    result =
      Redix.command!(:redix, [
        "GET",
        "client-session-token:#{token}"
      ])

    case result do
      nil ->
        # There is no matching token. This is a bad request/hacking attempt or someone waited too long (5+ minutes)

        conn
        |> send_resp(400, "Bad Request")

      player_id ->
        Redix.command!(:redix, [
          "DEL",
          "client-session-token:#{token}"
        ])

        [machine_id] = get_req_header(conn, "eoae-mid")

        token =
          Phoenix.Token.sign(MudWeb.Endpoint, "client_session", %{
            player_id: player_id,
            machine_id: machine_id
          })

        conn
        |> send_resp(200, Jason.encode!(%{token: token}))
    end
  end

  def sync(conn, _) do
    {:ok, player} = Mud.Account.Player.get(conn.assigns.player_id)

    player =
      Map.from_struct(player)
      |> Map.delete(:__meta__)
      |> Map.delete(:settings)

    characters = Character.list_by_player_id(player.id)

    conn
    |> put_status(200)
    |> put_view(MudWeb.Views.Api.V1)
    |> render("sync_player_characters.json", %{
      player: player,
      characters: characters
    })
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
      {:ok, player} ->
        conn
        |> configure_session(renew: true)
        |> put_flash(:info, "Successfully authenticated.")
        |> put_session(:player_id, player.id)
        |> redirect(to: "/")

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end
end
