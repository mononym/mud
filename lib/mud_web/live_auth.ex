defmodule MudWeb.LiveAuth do
  @moduledoc """
  Ensures that a player is authenticated and that common `assigns` are applied to all LiveViews attaching this hook.
  """
  import Phoenix.LiveView
  import MudWeb.PlayerAuth
  alias MudWeb.Router.Helpers, as: Routes

  def on_mount(:admin, _params, session, socket) do
    with true <- Map.has_key?(session, "player_token"),
         current_player <- fetch_current_player_live(session),
         true <- not is_nil(current_player)
    do
      {:cont, assign(socket, current_player: current_player, live_socket_id: Map.get(session, "live_socket_id"))}
    else
      false ->
        socket =
          socket
          |> put_flash(:error, "You must log in to access this page.")
          |> redirect(to: Routes.player_session_new_path(socket, :login))

          {:halt, socket}
    end
  end

  def on_mount(:player, _params, session, socket) do
    with true <- Map.has_key?(session, "player_token"),
         current_player <- fetch_current_player_live(session),
         true <- not is_nil(current_player)
    do
      {:cont, assign(socket, current_player: current_player, live_socket_id: Map.get(session, "live_socket_id"))}
    else
      false ->
        socket =
          socket
          |> put_flash(:error, "You must log in to access this page.")
          |> redirect(to: Routes.player_session_new_path(socket, :login))

          {:halt, socket}
    end
  end

  # Make sure default assigns are inserted so the liveview can operate normally
  def on_mount(:none, _params, session, socket) do
    with true <- Map.has_key?(session, "player_token"),
         current_player <- fetch_current_player_live(session),
         true <- not is_nil(current_player)
    do
      {:cont, assign(socket, current_player: current_player, live_socket_id: Map.get(session, "live_socket_id"))}
    else
      false ->
        {:cont, assign_new(socket, :current_player, fn -> nil end)}
    end
  end
end
