defmodule MudWeb.MudClientController do
  use MudWeb, :controller

  require Logger

  alias Mud.Engine

  action_fallback(MudWeb.FallbackController)

  plug(MudWeb.Plug.RedirectAnonymousPlayer, "/" when action in [:play])

  @spec play(Plug.Conn.t(), map) :: Plug.Conn.t()
  def play(conn, %{"character" => character_id}) do
    character = Engine.Model.Character.get_by_id!(character_id)

    if character.player_id === conn.assigns.player.id do
      Mud.Engine.start_character_session(character_id)

      # Send a silent look command
      Mud.Engine.Session.cast_message(%Mud.Engine.Input{
        id: UUID.uuid4(),
        character_id: character_id,
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
