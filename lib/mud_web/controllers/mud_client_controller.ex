defmodule MudWeb.MudClientController do
  use MudWeb, :controller

  action_fallback(MudWeb.FallbackController)

  plug(MudWeb.Plug.RedirectAnonymousPlayer, "/" when action in [:play])

  def play(conn, %{"character" => _character_id}) do
    # see if character exists
    # check if character belongs to authenticated player
    # start game session process for character
    conn
    |> put_layout("bare_page.html")
    |> render("landing_page.html")
  end
end
