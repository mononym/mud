defmodule MudWeb.Plug.HandleApiSession do
  import Plug.Conn
  require Logger

  def init(_params) do
  end

  def call(conn, _) do
    with [session_token] <- get_req_header(conn, "eoae-session"),
         {:ok, %{player_id: player_id, machine_id: machine_id}} <-
           Phoenix.Token.verify(MudWeb.Endpoint, "client_session", session_token,
             max_age: 2_592_000
           ),
         [provided_machine_id] = get_req_header(conn, "eoae-mid"),
         true <- machine_id === provided_machine_id do
      conn
      |> assign(:player_id, player_id)
      |> assign(:player_authenticated, true)
    else
      [] ->
        Logger.debug("no api session found")

        conn
        |> assign(:player_authenticated, false)

      {:error, _} ->
        Logger.debug("There was a problem with the token, either expired or invalid")

        conn
        |> assign(:player_authenticated, false)

      false ->
        Logger.debug("The machine id provided does not match the one given in the token")

        conn
        |> assign(:player_authenticated, false)
    end

    # case get_req_header(conn, "eoae-session") do
    #   [] ->
    #     Logger.debug("no api session found")

    #     conn
    #     |> assign(:player_authenticated, false)

    #   [session_token] ->
    #     Logger.debug("api session found")
    #     # Max age of a token is a month. Other mechanisms should be used to swap the token before
    #     # this period of time. This is simply a max-age backstop to help close security holes.
    #     case Phoenix.Token.verify(MudWeb.Endpoint, "client_session", session_token,
    #            max_age: 2_592_000
    #          ) do
    #       {:ok, %{player_id: player_id, machine_id: machine_id}} ->
    #         [provided_machine_id] = get_req_header(conn, "eoae-mid")

    #         conn
    #         |> assign(:player_id, player_id)
    #         |> assign(:player_authenticated, true)

    #       _ ->
    #         conn
    #     end
    # end
  end
end
