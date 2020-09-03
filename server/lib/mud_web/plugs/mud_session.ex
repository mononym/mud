defmodule MudWeb.Plug.MudSession do
  @moduledoc """
  A session is represented by a token which holds information for use by the server in identifying a player and
  securing the communication between them.

  A session token comes in two flavors, the original token and a refresh token. The session is considered invalid once
  the tokens has expired. To avoid dropping a session in the middle of play, however, sessions must be able to be
  extended while there is activity while preventing the extension of the session indefinitely.

  At the end of its lifetime an original token is exchanged for a refresh token. This refresh token will have its
  expiration time updated with every request, unlike an original token, and the session will be invalidated once the
  refresh token has expired.
  """

  import Plug.Conn

  alias MudWeb.MudSession


  def init(_params) do
  end

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(conn, _opts) do
    if Map.has_key?(conn.req_cookies, "token") do
      case MudSession.verify(conn.req_cookies["token"]) do
        {:ok, ""} ->
          conn
          |> assign(:player, nil)
          |> assign(:player_authenticated?, false)
        {:ok, player_id} ->
          conn
          |> assign(:player, player_id)
          |> assign(:player_authenticated?, true)
        {:error, _} ->
          conn
          |> assign(:player, nil)
          |> assign(:player_authenticated?, false)
      end
    else
      conn
      |> assign(:player, nil)
      |> assign(:player_authenticated?, false)
    end
  end
end
