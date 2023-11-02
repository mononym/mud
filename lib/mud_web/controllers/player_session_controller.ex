defmodule MudWeb.PlayerSessionController do
  use MudWeb, :controller

  alias Mud.Account
  alias MudWeb.PlayerAuth

  require Logger

  def create(conn, %{"player" => player_params}) do
    %{"email" => email, "password" => password} = player_params

    if player = Account.get_player_by_email_and_password(email, password) do
      Logger.info("Player succesfully logged in: #{player.id}")

      PlayerAuth.log_in_player(conn, player, player_params)
    else
      Logger.info("Player failed to log in.")

      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      redirect(conn, to: Routes.player_session_new_path(conn, :invalid))
    end
  end

  def delete(conn, _params) do
    Logger.info("Player logged out: #{conn.assigns.current_player.id}")

    conn
    |> put_flash(:info, "Logged out successfully.")
    |> PlayerAuth.log_out_player()
  end
end
