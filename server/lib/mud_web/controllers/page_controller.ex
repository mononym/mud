defmodule MudWeb.PageController do
  use MudWeb, :controller

  alias MudWeb.Schema.Email
  alias Mud.Engine

  action_fallback(MudWeb.FallbackController)

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
