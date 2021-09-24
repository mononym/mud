defmodule MudWeb.PageController do
  use MudWeb, :controller

  alias MudWeb.Schema.Email
  alias Mud.Engine

  action_fallback(MudWeb.FallbackController)

  plug(MudWeb.Plug.SetPlayer when action in [:store])

  def store(conn, _params) do
    timestamp = DateTime.utc_now() |> DateTime.to_unix()
    ecwid_config = Application.get_env(:mud, :ecwid)
    client_secret = ecwid_config[:client_secret]
    client_id = ecwid_config[:client_id]

    profile = Mud.Account.Profile.get!(conn.assigns.player_id)

    json =
      %{
        appClientId: client_id,
        userId: conn.assigns.player_id,
        profile: %{
          email: profile.email,
          billingPerson: %{name: profile.nickname}
        }
      }
      |> Jason.encode!()

    message =
      json
      |> Base.encode64()

    sig = :crypto.mac(:hmac, :sha, client_secret, "#{message} #{timestamp}") |> Base.encode16()

    final_string = "#{message} #{sig} #{timestamp}"

    render(conn, "store.html", ecwid_sso_string: final_string)
  end

  def play(conn, _params) do
    # create token to save/reference which can be linked to their player
    session_token = String.replace(UUID.uuid4(), "-", "")

    Redix.command!(:redix, [
      "SET",
      "client-session-token:#{session_token}",
      "#{conn.assigns.player_id}",
      "EX",
      300
    ])

    render(conn, "play.html", session_token: session_token)
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end

  plug(MudWeb.Plug.RedirectAuthenticatedPlayer, "/home" when action in [:show_landing_page])

  def show_landing_page(conn, _params) do
    conn
    |> assign(:changeset, Email.new() |> Email.changeset())
    |> put_layout("bare_page.html")
    |> render("landing_page.html")
  end

  plug(MudWeb.Plug.RedirectAnonymousPlayer, "/" when action in [:show_home_page])

  def show_home_page(conn, _params) do
    characters = Engine.Character.list_by_player_id(conn.assigns.player.id)
    characters_exist = not Enum.empty?(characters)

    conn
    |> assign(:changeset, Email.new() |> Email.changeset())
    |> put_layout("app.html")
    |> render("home_page.html", %{characters: characters, characters_exist: characters_exist})
  end
end
