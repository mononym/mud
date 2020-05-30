defmodule MudWeb.MudClientController do
  use MudWeb, :controller

  require Logger

  alias Mud.Engine

  action_fallback(MudWeb.FallbackController)

  plug(MudWeb.Plug.RedirectAnonymousPlayer, "/" when action in [:play])

  @spec play(Plug.Conn.t(), map) :: Plug.Conn.t()
  def play(conn, %{"character" => character_id}) do
    character = Engine.Character.get_by_id!(character_id)

    if character.player_id === conn.assigns.player.id do
      Engine.start_character_session(character_id)

      # Send a silent look command
      Engine.Session.cast_message(%Engine.Message.Input{
        id: UUID.uuid4(),
        to: character_id,
        text: "look",
        type: :silent
      })

      conn
      |> put_session(:character_id, character_id)
      |> put_layout("liveview_client_page.html")
      |> live_render(MudWeb.MudClientLive, character_id: character.id)
    else
      conn
      |> put_flash(:error, "You do not have permission to access that Character.")
      |> redirect(to: "/home")
    end
  end
end
