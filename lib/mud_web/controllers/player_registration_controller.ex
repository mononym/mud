defmodule MudWeb.PlayerRegistrationController do
  use MudWeb, :controller

  alias Mud.Account
  alias MudWeb.PlayerAuth
  alias MudWeb.Router.Helpers, as: Routes

  require Logger

  def create(conn, %{"player" => player_params}) do
    case Account.register_player(player_params) do
      {:ok, player} ->
        {:ok, _} =
          Account.deliver_player_confirmation_instructions(
            player,
            &Routes.player_registration_confirm_url(conn, :confirm, &1)
          )

          Logger.info("New player succesfully registered: #{player.id}")

        conn
        |> put_flash(:info, "Player created successfully.")
        |> PlayerAuth.log_in_player(player)

      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.warning("Error when attempting to register a new user: #{inspect(changeset.errors)}")

        redirect(conn, to: Routes.player_registration_new_path(conn, :register))
    end
  end
end
