defmodule MudWeb.MudClientController do
  use MudWeb, :controller

  import Phoenix.LiveView.Controller

  alias Mud.Engine

  action_fallback(MudWeb.FallbackController)

  plug(MudWeb.Plug.RedirectAnonymousPlayer, "/" when action in [:play])

  def play(conn, %{"character" => character_id}) do
    character = Engine.get_character!(character_id)

    if character.player_id === conn.assigns.player.id do
      conn
      |> put_session(:character_id, character_id)
      |> live_render(MudWeb.MudClientLive)
    else
      conn
      |> put_flash(:error, "You do not have permission to access that Character.")
      |> redirect(to: "/home")
    end
  end
end
