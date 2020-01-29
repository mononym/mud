defmodule MudWeb.PageController do
  use MudWeb, :controller

  alias MudWeb.Schema.Email

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
    conn
    |> assign(:changeset, Email.new() |> Email.changeset())
    |> put_layout("app_page.html")
    |> render("home_page.html")
  end
end
