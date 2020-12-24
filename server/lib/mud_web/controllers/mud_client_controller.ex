defmodule MudWeb.MudClientController do
  use MudWeb, :controller

  require Logger

  alias Mud.Engine

  @spec start_game_session(Plug.Conn.t(), map) :: Plug.Conn.t()
  def start_game_session(conn, %{"character_id" => character_id}) do
    Logger.debug("Attempting to start game session for #{character_id}")

    character = Engine.Character.get_by_id!(character_id)

    if character.player_id === conn.assigns.player_id do
      Logger.debug("Found #{character.name}")
      Logger.info("game_session:start:#{character_id}")

      Engine.start_character_session(character_id)

      # Send a silent look command
      # Engine.Session.cast_message_or_event(%Engine.Message.Input{
      #   id: UUID.uuid4(),
      #   to: character_id,
      #   text: "look",
      #   type: :silent
      # })

      token = Phoenix.Token.sign(MudWeb.Endpoint, "game session token", character.id)
      Logger.debug("Generated token for game session #{token}")

      # Plug.Crypto.MessageVerifier.verify(cookie, "ADkmDSNE")
      #   |> decode(:external_term_format, :fo)

      Logger.debug(get_session(conn))

      conn
      |> put_session(:character_id, character_id)
      |> put_status(201)
      |> render("start_game_session.json", token: token)
    else
      conn
      |> put_status(400)
      |> render("error.json", %{error: "error"})
    end
  end
end
