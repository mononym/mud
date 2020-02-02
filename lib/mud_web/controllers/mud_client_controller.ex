defmodule MudWeb.MudClientController do
  use MudWeb, :controller

  require Logger
  import Phoenix.LiveView.Controller

  alias Mud.Engine

  action_fallback(MudWeb.FallbackController)

  plug(MudWeb.Plug.RedirectAnonymousPlayer, "/" when action in [:play])

  def play(conn, %{"character" => character_id}) do
    Logger.debug("***** MudClientController.play() *****")
    character = Engine.get_character!(character_id)

    if character.player_id === conn.assigns.player.id do
      Mud.Engine.start_character_session(character_id)

      # Send a silent history command
      Mud.Engine.cast_message_to_character_session(%Mud.Engine.Input{
        id: UUID.uuid4(),
        character_id: character_id,
        text: "history",
        type: :silent
      })

      # Send a silent look command
      Mud.Engine.cast_message_to_character_session(%Mud.Engine.Input{
        id: UUID.uuid4(),
        character_id: character_id,
        text: "look",
        type: :silent
      })

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
